/// API falsa para os testes: responde como o backend, sem rede.
/// Uso: `http.runWithClient(() async { ... }, api.cliente)`.
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const servicosFalsos = [
  {'id': 1, 'nameServico': 'Corte Clássico', 'preco': 45.0, 'duracaoMinutos': 30},
  {'id': 2, 'nameServico': 'Corte + Barba', 'preco': 70.0, 'duracaoMinutos': 50},
  {'id': 3, 'nameServico': 'Barba Tradicional', 'preco': 35.0, 'duracaoMinutos': 20},
  {'id': 4, 'nameServico': 'Corte Premium', 'preco': 80.0, 'duracaoMinutos': 45},
];

class ApiFalsa {
  /// Requisições recebidas, para os testes conferirem.
  final requisicoes = <http.Request>[];

  http.Client cliente() => MockClient((request) async {
        requisicoes.add(request);
        final caminho = request.url.path;

        if (caminho.endsWith('/ServicosControlador')) {
          if (request.method == 'GET') return _json(servicosFalsos);
          if (request.method == 'POST') {
            final dados = jsonDecode(request.body) as Map<String, dynamic>;
            return _json({...dados, 'ID': 99});
          }
        }
        return http.Response('nao encontrado', 404);
      });

  static http.Response _json(Object dados) => http.Response.bytes(
        utf8.encode(jsonEncode(dados)),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
}
