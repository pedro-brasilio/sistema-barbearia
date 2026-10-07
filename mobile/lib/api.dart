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

  /// Token de login devolvido pela API no login e no cadastro. Fica só na
  /// memória, como o usuário logado: ao fechar o app é preciso entrar de novo.
  static String? token;

  static Map<String, String> get _headers => {
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Map<String, String> get _jsonHeaders => {
        'Content-Type': 'application/json',
        ..._headers,
      };
  // A API gratuita do Render leva cerca de 1 minuto para "acordar" depois de
  // 15 minutos sem acesso, então a espera precisa ser maior que isso.
  static const _timeout = Duration(seconds: 90);

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

  /// Igual ao mensagemDeErro do api.ts: avisa quando o login venceu.
  static String _mensagemDeErro(
    http.Response res,
    dynamic data,
    String fallback,
  ) {
    if (res.statusCode == 401) {
      return 'Sua sessão expirou. Saia e entre de novo.';
    }
    if (res.statusCode == 403) return 'Você não tem permissão para isso.';
    return data is String && data.isNotEmpty ? data : fallback;
  }

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
    token = data is Map ? data['token'] as String? : null;
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
    token = data is Map ? data['token'] as String? : null;
    return data;
  }

  static Future<dynamic> listarAgendamentos() async {
    final res = await _send(
      http.get(_uri('/Agedamentocontrolador'), headers: _headers),
    );
    if (!_ok(res)) {
      throw ApiException(
        _mensagemDeErro(res, null, 'Erro ao buscar agendamentos.'),
      );
    }
    return _parseResponse(res);
  }

  static Future<dynamic> listarAgendamentosCliente(int clienteId) async {
    final res = await _send(
      http.get(
        _uri('/Agedamentocontrolador/cliente/$clienteId'),
        headers: _headers,
      ),
    );
    if (!_ok(res)) {
      throw ApiException(
        _mensagemDeErro(res, null, 'Erro ao buscar agendamentos.'),
      );
    }
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
      throw ApiException(
        _mensagemDeErro(res, body, 'Erro ao criar agendamento.'),
      );
    }
    return body;
  }

  static Future<dynamic> confirmarAgendamento(int id) async {
    final res = await _send(
      http.patch(
        _uri('/Agedamentocontrolador/$id/confirmar'),
        headers: _headers,
      ),
    );
    final data = _parseResponse(res);
    if (!_ok(res)) {
      throw ApiException(_mensagemDeErro(res, data, 'Erro ao confirmar.'));
    }
    return data;
  }

  static Future<dynamic> deletarAgendamento(int id) async {
    final res = await _send(
      http.delete(_uri('/Agedamentocontrolador/$id'), headers: _headers),
    );
    final data = _parseResponse(res);
    if (!_ok(res)) {
      throw ApiException(_mensagemDeErro(res, data, 'Erro ao deletar.'));
    }
    return data;
  }

  static Future<dynamic> listarServicos() async {
    final res = await _send(http.get(_uri('/ServicosControlador')));
    if (!_ok(res)) throw ApiException('Erro ao buscar os serviços.');
    return _parseResponse(res);
  }

  /// Cadastrar, alterar e remover serviços: só o administrador
  /// (aba ADMIN > SERVIÇOS).
  static String _corpoServico(
    int id,
    String nome,
    double preco,
    int duracaoMinutos,
  ) =>
      jsonEncode({
        'ID': id,
        'NameServico': nome,
        'Preco': preco,
        'DuracaoMinutos': duracaoMinutos,
      });

  static Future<dynamic> criarServico({
    required String nome,
    required double preco,
    required int duracaoMinutos,
  }) async {
    final res = await _send(http.post(
      _uri('/ServicosControlador'),
      headers: _jsonHeaders,
      body: _corpoServico(0, nome, preco, duracaoMinutos),
    ));
    final data = _parseResponse(res);
    if (!_ok(res)) {
      throw ApiException(
        _mensagemDeErro(res, data, 'Erro ao cadastrar o serviço.'),
      );
    }
    return data;
  }

  static Future<dynamic> atualizarServico({
    required int id,
    required String nome,
    required double preco,
    required int duracaoMinutos,
  }) async {
    final res = await _send(http.put(
      _uri('/ServicosControlador/$id'),
      headers: _jsonHeaders,
      body: _corpoServico(id, nome, preco, duracaoMinutos),
    ));
    final data = _parseResponse(res);
    if (!_ok(res)) {
      throw ApiException(
        _mensagemDeErro(res, data, 'Erro ao salvar o serviço.'),
      );
    }
    return data;
  }

  static Future<dynamic> removerServico(int id) async {
    final res = await _send(
      http.delete(_uri('/ServicosControlador/$id'), headers: _headers),
    );
    final data = _parseResponse(res);
    if (!_ok(res)) {
      throw ApiException(
        _mensagemDeErro(res, data, 'Erro ao remover o serviço.'),
      );
    }
    return data;
  }

  /// Notificações push (aba ADMIN): quantos clientes com o app recebem.
  static Future<dynamic> contarPublicoNotificacao(String filtro) async {
    final res = await _send(http.get(
      _uri(
        '/Notificacaocontrolador/publico'
        '?filtro=${Uri.encodeQueryComponent(filtro)}',
      ),
      headers: _headers,
    ));
    final data = _parseResponse(res);
    if (!_ok(res)) {
      throw ApiException(
        _mensagemDeErro(res, data, 'Erro ao contar os clientes.'),
      );
    }
    return data;
  }

  static Future<dynamic> enviarNotificacao({
    required String titulo,
    required String mensagem,
    required String filtro,
  }) async {
    final res = await _send(http.post(
      _uri('/Notificacaocontrolador/enviar'),
      headers: _jsonHeaders,
      body: jsonEncode({
        'Titulo': titulo,
        'Mensagem': mensagem,
        'Filtro': filtro,
      }),
    ));
    final data = _parseResponse(res);
    if (!_ok(res)) {
      throw ApiException(
        _mensagemDeErro(res, data, 'Erro ao enviar a notificação.'),
      );
    }
    return data;
  }

  /// Só existe no app: guarda o token do Firebase deste celular no cliente,
  /// para ele receber as notificações enviadas pelo n8n (ver push.dart).
  static Future<void> salvarTokenPush(int clienteId, String tokenPush) async {
    final res = await _send(http.put(
      _uri('/Clientecontrolador/$clienteId/token-push'),
      headers: _jsonHeaders,
      body: jsonEncode({'Token': tokenPush}),
    ));
    if (!_ok(res)) {
      throw ApiException(_mensagemDeErro(
        res,
        _parseResponse(res),
        'Erro ao salvar o token das notificações.',
      ));
    }
  }
}
