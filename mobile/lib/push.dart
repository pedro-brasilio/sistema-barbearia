/// Notificações push (Firebase Cloud Messaging) no app Android.
///
/// O administrador envia avisos e promoções pela aba ADMIN do site ou do app.
/// A API escolhe os clientes pelo filtro e chama o workflow do n8n (pasta
/// n8n/ na raiz do repositório), que manda para cada token pelo Firebase.
///
/// As chaves do projeto Firebase vêm do build, como a API_URL:
///   flutter run --dart-define=FIREBASE_API_KEY=... --dart-define=FIREBASE_APP_ID=...
///               --dart-define=FIREBASE_SENDER_ID=... --dart-define=FIREBASE_PROJECT_ID=...
/// Sem elas o app funciona normalmente, só não recebe notificações.
library;

import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api.dart';

class Push {
  Push._();

  static const _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const _senderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const _projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  /// Só o APK Android recebe notificações (a versão web e o iOS ficam de fora).
  static bool get _disponivel =>
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _senderId.isNotEmpty &&
      _projectId.isNotEmpty &&
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android;

  static Future<bool>? _inicializacao;
  static StreamSubscription<String>? _trocaDeToken;

  /// Liga o Firebase uma vez só. Devolve false quando não há notificações.
  static Future<bool> _inicializar() {
    return _inicializacao ??= () async {
      if (!_disponivel) return false;
      try {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: _apiKey,
            appId: _appId,
            messagingSenderId: _senderId,
            projectId: _projectId,
          ),
        );
        return true;
      } catch (err) {
        debugPrint('Notificações indisponíveis: $err');
        return false;
      }
    }();
  }

  /// Com o app aberto o Android não mostra a notificação sozinho,
  /// então ela é repassada para [aoReceber] (que mostra uma SnackBar).
  static Future<void> iniciar({
    required void Function(RemoteNotification notificacao) aoReceber,
  }) async {
    if (!await _inicializar()) return;
    FirebaseMessaging.onMessage.listen((mensagem) {
      final notificacao = mensagem.notification;
      if (notificacao != null) aoReceber(notificacao);
    });
  }

  /// Chamado depois do login: pede permissão para mostrar notificações
  /// (Android 13 ou mais novo) e liga este celular ao cliente na API.
  static Future<void> registrar(int clienteId) async {
    if (!await _inicializar()) return;
    try {
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();

      final token = await messaging.getToken();
      if (token != null) await Api.salvarTokenPush(clienteId, token);

      // O Firebase pode trocar o token (ex.: depois de limpar os dados do app).
      await _trocaDeToken?.cancel();
      _trocaDeToken = messaging.onTokenRefresh.listen((novoToken) {
        Api.salvarTokenPush(clienteId, novoToken).catchError((Object err) {
          debugPrint('Erro ao atualizar o token das notificações: $err');
        });
      });
    } catch (err) {
      debugPrint('Erro ao registrar as notificações: $err');
    }
  }
}
