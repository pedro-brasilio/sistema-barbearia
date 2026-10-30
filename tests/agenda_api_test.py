"""Integration checks for the weekly agenda against an isolated PostgreSQL database.

Build the API in Release, set PIM_TEST_DB_CONNECTION, then run this script.
The script starts its own API, creates synthetic accounts and appointments, and
removes the records it creates. Never point it at a production database.
"""
from __future__ import annotations
import json
import os
from pathlib import Path
import socket
import subprocess
import sys
import time
import urllib.error
import urllib.request
import uuid

ROOT = Path(__file__).resolve().parents[1]
passed = []

def main():
    connection = os.environ.get('PIM_TEST_DB_CONNECTION')
    if not connection:
        raise RuntimeError('Set PIM_TEST_DB_CONNECTION to an isolated test database.')
    dll = ROOT / 'backend/bin/Release/net10.0/barbearia.dll'
    if not dll.exists():
        raise RuntimeError('Build first: dotnet build backend/barbearia.csproj -c Release')
    with socket.socket() as probe:
        probe.bind(('127.0.0.1', 0))
        port = probe.getsockname()[1]
    base = f'http://127.0.0.1:{port}/api'
    admin_email = 'pim-test-admin@example.invalid'
    password = 'Synthetic-test-password-2026!'
    environment = dict(os.environ, ASPNETCORE_ENVIRONMENT='Development',
        ASPNETCORE_URLS=f'http://127.0.0.1:{port}',
        ConnectionStrings__DefaultConnection=connection,
        Admin__Email=admin_email, Admin__Senha=password,
        Jwt__Chave='pim-isolated-integration-test-key-2026-0123456789abcdef')
    appointment_id = None
    client_id = None
    admin_token = None

    def request(method, path, body=None, token=None):
        headers = {'Content-Type': 'application/json'}
        if token:
            headers['Authorization'] = 'Bearer ' + token
        data = json.dumps(body).encode('utf-8') if body is not None else None
        req = urllib.request.Request(base + path, data=data, headers=headers, method=method)
        try:
            response = urllib.request.urlopen(req, timeout=15)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            raw = response.read().decode('utf-8')
            try:
                payload = json.loads(raw)
            except json.JSONDecodeError:
                payload = raw
            return response.status, payload

    def check(condition, description):
        if not condition:
            raise AssertionError(description)
        passed.append(description)
        print('PASS:', description, flush=True)

    flags = subprocess.CREATE_NO_WINDOW if os.name == 'nt' else 0
    with open(ROOT / 'tests/agenda_api_run.log', 'w', encoding='utf-8') as log:
        process = subprocess.Popen(['dotnet', str(dll)], cwd=ROOT / 'backend',
            env=environment, stdout=log, stderr=subprocess.STDOUT, creationflags=flags)
        try:
            deadline = time.monotonic() + 60
            while True:
                if process.poll() is not None:
                    raise RuntimeError('API exited; inspect tests/agenda_api_run.log')
                try:
                    status, _ = request('GET', '/ServicosControlador')
                    if status == 200:
                        break
                except (OSError, urllib.error.URLError):
                    pass
                if time.monotonic() > deadline:
                    raise TimeoutError('API startup exceeded 60 seconds; inspect its log.')
                time.sleep(0.25)

            status, _ = request('GET', '/Agedamentocontrolador/semana?data=2026-10-30')
            check(status == 401, 'Weekly agenda rejects anonymous access (401)')
            status, admin = request('POST', '/authcontrolador/login',
                {'Email': admin_email, 'senha': password})
            check(status == 200 and admin.get('isAdmin'), 'Test administrator authenticates')
            admin_token = admin['token']
            email = f'agenda-{uuid.uuid4().hex}@example.invalid'
            status, client = request('POST', '/Clientecontrolador/cadastro',
                {'Nome': 'Cliente de teste da agenda', 'Email': email,
                 'Telefone': '00000000000', 'senha': password})
            check(status == 200 and not client.get('isAdmin'), 'Public registration creates a regular client')
            client_id = client['id']
            client_token = client['token']
            status, _ = request('GET', '/Agedamentocontrolador/semana?data=2026-10-30', token=client_token)
            check(status == 403, 'Weekly agenda rejects regular clients (403)')
            status, _ = request('GET', '/Agedamentocontrolador/semana?data=invalid', token=admin_token)
            check(status == 400, 'Invalid reference date is rejected (400)')
            status, _ = request('GET', '/Agedamentocontrolador/semana?data=9999-12-31', token=admin_token)
            check(status == 400, 'Reference beyond complete supported week is rejected (400)')

            appointment = {'Clienteid': admin['id'], 'Barbeiroid': 1,
                'Servicos': 'Corte de teste', 'Data': '2026-10-30',
                'DataHorainicio': '09:30:00', 'Situacao': 'confirmado'}
            status, created = request('POST', '/Agedamentocontrolador', appointment, client_token)
            check(status == 200, 'Client appointment is persisted by the API')
            appointment_id = created['id']
            check(created['clienteid'] == client_id and created['situacao'] == 'pendente',
                'API enforces appointment ownership and pending initial status')

            def agenda(day):
                status, value = request('GET', '/Agedamentocontrolador/semana?data=' + day, token=admin_token)
                check(status == 200, 'Weekly query succeeds for ' + day)
                return value
            value = agenda('2026-11-01')
            matches = [item for item in value['agendamentos'] if item['id'] == appointment_id]
            check(value['inicioSemana'] == '2026-10-26' and value['fimSemana'] == '2026-11-01',
                'Sunday reference normalizes to Monday through Sunday')
            check(len(matches) == 1 and matches[0]['clienteNome'] == client['nome'],
                'AFTER INSERT makes the new appointment immediately queryable with client data')
            check(not any(k in matches[0] for k in ['senha', 'tokenPush']),
                'Weekly response does not expose password or push token')
            status, _ = request('PATCH', f'/Agedamentocontrolador/{appointment_id}/confirmar', token=admin_token)
            check(status == 200, 'Administrator confirms appointment')
            confirmed = [item for item in agenda('2026-10-30')['agendamentos'] if item['id'] == appointment_id]
            check(len(confirmed) == 1 and confirmed[0]['situacao'] == 'confirmado',
                'Confirmation keeps a single weekly entry with fresh status')

            updated = dict(created, data='2026-11-02', situacao='confirmado')
            status, _ = request('PUT', f'/Agedamentocontrolador/{appointment_id}', updated, admin_token)
            check(status == 200, 'Administrator reschedules appointment')
            check(not any(item['id'] == appointment_id for item in agenda('2026-10-30')['agendamentos']),
                'AFTER UPDATE removes rescheduled appointment from the old week')
            check(sum(item['id'] == appointment_id for item in agenda('2026-11-02')['agendamentos']) == 1,
                'AFTER UPDATE classifies the appointment in its new week without duplication')
            updated['situacao'] = 'cancelado'
            status, _ = request('PUT', f'/Agedamentocontrolador/{appointment_id}', updated, admin_token)
            check(status == 200 and not any(item['id'] == appointment_id for item in agenda('2026-11-02')['agendamentos']),
                'Cancellation by status removes the weekly classification')
            updated['situacao'] = 'pendente'
            status, _ = request('PUT', f'/Agedamentocontrolador/{appointment_id}', updated, admin_token)
            check(status == 200 and any(item['id'] == appointment_id for item in agenda('2026-11-02')['agendamentos']),
                'Reactivation restores the weekly classification')
            status, _ = request('DELETE', f'/Agedamentocontrolador/{appointment_id}', token=client_token)
            check(status == 200, 'Client can remove their own appointment')
            check(not any(item['id'] == appointment_id for item in agenda('2026-11-02')['agendamentos']),
                'Deletion removes the weekly entry by cascade')
            appointment_id = None
            print(f'OK: {len(passed)} integration assertions passed.', flush=True)
        finally:
            try:
                if admin_token and appointment_id:
                    request('DELETE', f'/Agedamentocontrolador/{appointment_id}', token=admin_token)
                if admin_token and client_id:
                    request('DELETE', f'/Clientecontrolador/{client_id}', token=admin_token)
            finally:
                process.terminate()
                try:
                    process.wait(timeout=10)
                except subprocess.TimeoutExpired:
                    process.kill()
                    process.wait(timeout=5)

if __name__ == '__main__':
    main()
