import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:barbershop_mobile/api.dart';
import 'package:barbershop_mobile/models.dart';
import 'package:barbershop_mobile/pages/admin_page.dart';
import 'package:barbershop_mobile/theme.dart';
import 'package:barbershop_mobile/utils/dates.dart';
import 'package:barbershop_mobile/widgets/weekly_agenda.dart';

http.Response agendaResponse(
  String date, {
  bool hasItem = true,
  bool confirmed = false,
}) {
  final start = weekStartIso(date);
  return http.Response.bytes(
    utf8.encode(
      jsonEncode({
        'inicioSemana': start,
        'fimSemana': shiftIsoDays(start, 6),
        'agendamentos': [
          if (hasItem)
            {
              'id': 71,
              'clienteid': 2,
              'barbeiroid': 1,
              'clienteNome': 'Cliente da Semana',
              'clienteTelefone': '(11) 99999-0000',
              'servicos': 'Corte Clássico',
              'data': start,
              'dataHorainicio': '10:00:00',
              'situacao': confirmed ? 'confirmado' : 'pendente',
            },
        ],
      }),
    ),
    200,
    headers: {'content-type': 'application/json'},
  );
}

Future<void> openAgenda(
  WidgetTester tester, {
  FutureOr<void> Function(String, AppointmentStatus)? onConfirm,
  FutureOr<void> Function(String)? onDelete,
}) async {
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: WeeklyAgenda(
            revision: 0,
            initialDate: '2027-01-03',
            onUpdateStatus: onConfirm ?? (_, __) {},
            onDeleteAppointment: onDelete ?? (_) {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  tearDown(() => Api.token = null);

  test('domingo e segunda usam semanas ISO distintas na virada do ano', () {
    expect(weekStartIso('2027-01-03'), '2026-12-28');
    expect(weekStartIso('2027-01-04'), '2027-01-04');
    expect(shiftIsoDays('2026-12-28', 6), '2027-01-03');
    expect(shiftIsoDays('2024-02-26', 6), '2024-03-03');
  });

  testWidgets('consulta a semana com autenticação e navega para a próxima', (
    tester,
  ) async {
    final requests = <http.Request>[];
    Api.token = 'token-admin-teste';
    await http.runWithClient(
      () async {
        await openAgenda(tester);
        await tester.pumpAndSettle();
        expect(find.text('28/12/2026 a 03/01/2027'), findsOneWidget);
        expect(find.text('Cliente da Semana'), findsOneWidget);
        await tester.tap(find.byTooltip('Próxima semana'));
        await tester.pumpAndSettle();
        expect(find.text('04/01/2027 a 10/01/2027'), findsOneWidget);
      },
      () => MockClient((request) async {
        requests.add(request);
        expect(request.url.path, endsWith('/Agedamentocontrolador/semana'));
        expect(request.headers['Authorization'], 'Bearer token-admin-teste');
        return agendaResponse(request.url.queryParameters['data']!);
      }),
    );
    expect(requests.map((r) => r.url.queryParameters['data']).toList(), [
      '2026-12-28',
      '2027-01-04',
    ]);
  });

  testWidgets('confirma e remove no servidor e consulta novamente a agenda', (
    tester,
  ) async {
    var confirmed = false;
    var hasItem = true;
    final methods = <String>[];
    await http.runWithClient(
      () async {
        await openAgenda(
          tester,
          onConfirm: (id, _) async {
            await Api.confirmarAgendamento(int.parse(id));
          },
          onDelete: (id) async {
            await Api.deletarAgendamento(int.parse(id));
          },
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('CONFIRMAR'));
        await tester.pumpAndSettle();
        expect(find.text('CONFIRMADO'), findsOneWidget);
        expect(find.text('CONFIRMAR'), findsNothing);
        await tester.tap(find.text('REMOVER'));
        await tester.pumpAndSettle();
        expect(find.text('Nenhum agendamento nesta semana.'), findsOneWidget);
        expect(find.text('Cliente da Semana'), findsNothing);
      },
      () => MockClient((request) async {
        methods.add(request.method);
        if (request.method == 'PATCH') {
          confirmed = true;
          return http.Response('{}', 200);
        }
        if (request.method == 'DELETE') {
          hasItem = false;
          return http.Response('{}', 200);
        }
        return agendaResponse(
          request.url.queryParameters['data']!,
          hasItem: hasItem,
          confirmed: confirmed,
        );
      }),
    );
    expect(methods, ['GET', 'PATCH', 'GET', 'DELETE', 'GET']);
  });

  testWidgets(
    'resposta atrasada da semana anterior não sobrescreve a seleção',
    (tester) async {
      final first = Completer<http.Response>();
      await http.runWithClient(
        () async {
          await openAgenda(tester);
          await tester.pump();
          await tester.tap(find.byTooltip('Próxima semana'));
          await tester.pumpAndSettle();
          expect(find.text('04/01/2027 a 10/01/2027'), findsOneWidget);
          first.complete(agendaResponse('2026-12-28'));
          await tester.pumpAndSettle();
          expect(find.text('04/01/2027 a 10/01/2027'), findsOneWidget);
          expect(find.text('28/12/2026 a 03/01/2027'), findsNothing);
        },
        () => MockClient((request) {
          final date = request.url.queryParameters['data']!;
          return date == '2026-12-28'
              ? first.future
              : Future.value(agendaResponse(date));
        }),
      );
    },
  );

  testWidgets('403 apresenta falta de permissão sem dados de clientes', (
    tester,
  ) async {
    await http.runWithClient(() async {
      await openAgenda(tester);
      await tester.pumpAndSettle();
      expect(find.text('Você não tem permissão para isso.'), findsOneWidget);
      expect(find.text('Cliente da Semana'), findsNothing);
    }, () => MockClient((_) async => http.Response('Forbidden', 403)));
  });

  testWidgets('cliente não recebe a aba de agenda semanal', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: Scaffold(
          body: AdminPage(
            appointments: const [],
            isAdmin: false,
            onUpdateStatus: (_, __) {},
            onDeleteAppointment: (_) {},
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('AGENDA SEMANAL'), findsNothing);
  });
}
