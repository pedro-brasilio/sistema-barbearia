import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barbershop_mobile/pages/admin_page.dart';
import 'package:barbershop_mobile/theme.dart';

void main() {
  Future<void> abrirPainel(WidgetTester tester, {bool isAdmin = false}) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        body: AdminPage(
          appointments: const [],
          isAdmin: isAdmin,
          onUpdateStatus: (_, __) {},
          onDeleteAppointment: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('sem admin logado não mostra as abas', (tester) async {
    await abrirPainel(tester);

    expect(find.text('PAINEL DE AGENDAMENTOS'), findsOneWidget);
    expect(find.text('NOTIFICAÇÕES'), findsNothing);
  });

  testWidgets('aba NOTIFICAÇÕES mostra o formulário de envio', (tester) async {
    await abrirPainel(tester, isAdmin: true);

    await tester.tap(find.text('NOTIFICAÇÕES'));
    await tester.pumpAndSettle();

    // Título do card e botão.
    expect(find.text('ENVIAR NOTIFICAÇÃO'), findsNWidgets(2));
    expect(find.text('TÍTULO'), findsOneWidget);
    expect(find.text('MENSAGEM'), findsOneWidget);
    expect(find.text('ENVIAR PARA'), findsOneWidget);
    expect(find.text('Todos os clientes'), findsOneWidget);
    // Nos testes não há API: a contagem de clientes falha.
    expect(find.text('Não foi possível contar os clientes.'), findsOneWidget);

    // O botão só habilita com título e mensagem preenchidos.
    double opacidadeDoBotao() => tester
        .widget<Opacity>(find
            .ancestor(
              of: find.text('ENVIAR NOTIFICAÇÃO').last,
              matching: find.byType(Opacity),
            )
            .first)
        .opacity;
    expect(opacidadeDoBotao(), 0.4);

    final campos = find.byType(TextFormField);
    await tester.enterText(campos.at(0), 'Promoção de outubro');
    await tester.enterText(campos.at(1), 'Olá {nome}! 20% de desconto.');
    await tester.pump();

    expect(opacidadeDoBotao(), 1);
    expect(find.text('19/65'), findsOneWidget);

    // Volta para os agendamentos.
    await tester.tap(find.text('AGENDAMENTOS'));
    await tester.pumpAndSettle();
    expect(find.text('PAINEL DE AGENDAMENTOS'), findsOneWidget);
    expect(find.text('Nenhum agendamento encontrado'), findsOneWidget);
  });
}
