import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:barbershop_mobile/app.dart';

import 'api_falsa.dart';

void main() {
  Future<void> abrirApp(WidgetTester tester) async {
    // Tela de celular: 360 x 780.
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    // Os serviços vêm da API (aqui, a falsa).
    await http.runWithClient(() async {
      await tester.pumpWidget(const BarbershopApp());
      await tester.pumpAndSettle();
    }, ApiFalsa().cliente);
  }

  testWidgets('abre na tela inicial com o hero e os serviços', (tester) async {
    await abrirApp(tester);

    expect(find.text('BARBERSHOP'), findsOneWidget);
    expect(find.text('DESDE 1998'), findsOneWidget);
    expect(find.text('AGENDAR HORÁRIO'), findsOneWidget);
    expect(find.text('Corte Clássico'), findsOneWidget);
    expect(find.text(r'R$ 45'), findsOneWidget);
    expect(find.text('20 min'), findsOneWidget);
    expect(find.text('INÍCIO'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
    // ADMIN só aparece para administradores.
    expect(find.text('ADMIN'), findsNothing);
  });

  testWidgets('agendar sem login mostra o bloqueio', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('AGENDAR HORÁRIO'));
    await tester.pumpAndSettle();

    expect(find.text('AGENDE SEU HORÁRIO'), findsOneWidget);
    expect(find.text('FAÇA LOGIN PARA AGENDAR'), findsOneWidget);
    expect(find.text('Faça login para ver seus agendamentos.'), findsOneWidget);

    await tester.tap(find.text('IR PARA O LOGIN'));
    await tester.pumpAndSettle();

    expect(find.text('ENTRAR'), findsOneWidget);
  });

  testWidgets('login alterna para cadastro e valida as senhas', (tester) async {
    await abrirApp(tester);

    await tester.tap(find.text('LOGIN'));
    await tester.pumpAndSettle();
    expect(find.text('Esqueceu a senha?'), findsOneWidget);

    await tester.ensureVisible(find.text('CLIQUE AQUI'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('CLIQUE AQUI'));
    await tester.pumpAndSettle();
    expect(find.text('CADASTRO'), findsOneWidget);
    expect(find.text('CONFIRMAR SENHA'), findsOneWidget);

    final campos = find.byType(TextFormField);
    expect(campos, findsNWidgets(5));
    await tester.enterText(campos.at(0), 'Maria Souza');
    await tester.enterText(campos.at(1), 'maria@email.com');
    await tester.enterText(campos.at(2), '(11) 99999-9999');
    await tester.enterText(campos.at(3), 'senha123');
    await tester.enterText(campos.at(4), 'outra456');

    await tester.ensureVisible(find.text('CRIAR CONTA'));
    await tester.tap(find.text('CRIAR CONTA'));
    await tester.pumpAndSettle();

    expect(find.text('As senhas não coincidem.'), findsOneWidget);
  });
}
