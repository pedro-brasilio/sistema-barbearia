/// Versão em Dart do frontend/src/api.ts.
/// Mesmos endpoints, mesmos campos e mesmas mensagens de erro.
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class Api {
  Api._();

  /// Permite trocar o endereço da API sem mexer no código:
  /// flutter run --dart-define=API_URL=http://192.168.0.10:5039/api
  static const _apiUrlOverride = String.fromEnvironment('API_URL');

  /// Mesmo backend do site (http://localhost:5039/api).
  /// No emulador Android, "localhost" é o próprio emulador. O computador
  /// fica acessível pelo endereço especial 10.0.2.2.
  static String get baseUrl {
    if (_apiUrlOverride.isNotEmpty) return _apiUrlOverride;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5039/api';
    }
    return 'http://localhost:5039/api';
  }

  static const _jsonHeaders = {'Content-Type': 'application/json'};
  static const _timeout = Duration(seconds: 15);

  static Uri _uri(String path) => Uri.parse('$baseUrl$path');

  /// Equivalente ao parseResponse do api.ts: JSON quando possível,
  /// texto puro quando não, null quando vazio.
  static dynamic _parseResponse(http.Response res) {
    final text = utf8.decode(res.bodyBytes, allowMalformed: true);
    if (text.isEmpty) return null;
    try {
      return jsonDecode(text);
    } catch (_) {
      return text;
    }
  }

  static bool _ok(http.Response res) =>
      res.statusCode >= 200 && res.statusCode < 300;

  /// typeof data === 'string' ? data : data?.message || fallback
  static String _errorWithMessage(dynamic data, String fallback) {
    if (data is String) return data;
    if (data is Map) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) return message;
    }
    return fallback;
  }

  /// typeof data === 'string' ? data : fallback
  static String _errorText(dynamic data, String fallback) =>
      data is String ? data : fallback;

  static Future<http.Response> _send(Future<http.Response> request) async {
    try {
      return await request.timeout(_timeout);
    } on TimeoutException {
      throw ApiException('Tempo esgotado ao conectar com a API ($baseUrl).');
    } catch (_) {
      throw ApiException(
        'Não foi possível conectar à API ($baseUrl). '
        'Verifique se o backend está rodando.',
      );
    }
  }

  static Future<dynamic> cadastrarCliente({
    required String nome,
    required String telefone,
    required String email,
    required String senha,
  }) async {
    final res = await _send(http.post(
      _uri('/Clientecontrolador/cadastro'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'Nome': nome,
        'Telefone': telefone,
        'Email': email,
        'senha': senha,
      }),
    ));
    final data = _parseResponse(res);
    if (!_ok(res)) {
      throw ApiException(_errorWithMessage(data, 'Erro ao cadastrar.'));
    }
    return data;
  }

  static Future<dynamic> loginCliente({
    required String email,
    required String senha,
  }) async {
    final res = await _send(http.post(
      _uri('/authcontrolador/login'),
      headers: _jsonHeaders,
      body: jsonEncode({'Email': email, 'senha': senha}),
    ));
    final data = _parseResponse(res);
    if (!_ok(res)) {
      throw ApiException(_errorWithMessage(data, 'Email ou senha incorretos.'));
    }
    return data;
  }

  static Future<dynamic> listarAgendamentos() async {
    final res = await _send(http.get(_uri('/Agedamentocontrolador')));
    if (!_ok(res)) throw ApiException('Erro ao buscar agendamentos.');
    return _parseResponse(res);
  }

  static Future<dynamic> listarAgendamentosCliente(int clienteId) async {
    final res = await _send(
      http.get(_uri('/Agedamentocontrolador/cliente/$clienteId')),
    );
    if (!_ok(res)) throw ApiException('Erro ao buscar agendamentos.');
    return _parseResponse(res);
  }

  static Future<dynamic> criarAgendamento({
    required int clienteId,
    required int barbeiroId,
    required String servicos,
    required String data,
    required String dataHoraInicio,
    required String situacao,
  }) async {
    final res = await _send(http.post(
      _uri('/Agedamentocontrolador'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'Clienteid': clienteId,
        'Barbeiroid': barbeiroId,
        'Servicos': servicos,
        'Data': data,
        'DataHorainicio': dataHoraInicio,
        'Situacao': situacao,
      }),
    ));
    final body = _parseResponse(res);
    if (!_ok(res)) {
      throw ApiException(_errorWithMessage(body, 'Erro ao criar agendamento.'));
    }
    return body;
  }

  static Future<dynamic> confirmarAgendamento(int id) async {
    final res = await _send(
      http.patch(_uri('/Agedamentocontrolador/$id/confirmar')),
    );
    final data = _parseResponse(res);
    if (!_ok(res)) throw ApiException(_errorText(data, 'Erro ao confirmar.'));
    return data;
  }

  static Future<dynamic> deletarAgendamento(int id) async {
    final res = await _send(http.delete(_uri('/Agedamentocontrolador/$id')));
    final data = _parseResponse(res);
    if (!_ok(res)) throw ApiException(_errorText(data, 'Erro ao deletar.'));
    return data;
  }
}
