import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:barbershop_mobile/models.dart';
import 'package:barbershop_mobile/pages/admin_page.dart';
import 'package:barbershop_mobile/theme.dart';

import 'api_falsa.dart';

void main() {
  final servicos = [
    for (final json in servicosFalsos) Servico.fromApi(json),
  ];

  Future<void> abrirAbaServicos(
    WidgetTester tester, {
    required Future<void> Function() onAlterado,
  }) async {
    tester.view.physicalSize = const Size(1080, 2340);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        body: AdminPage(
          appointments: const [],
          isAdmin: true,
          servicos: servicos,
          onServicosAlterados: onAlterado,
          onUpdateStatus: (_, __) {},
          onDeleteAppointment: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('SERVIÇOS'));
    await tester.pumpAndSettle();
  }

  testWidgets('aba SERVIÇOS lista os serviços e abre um para editar',
      (tester) async {
    await abrirAbaServicos(tester, onAlterado: () async {});

    expect(find.text('SERVIÇOS OFERECIDOS'), findsOneWidget);
    expect(find.text('NOVO SERVIÇO'), findsOneWidget);
    expect(find.text('Corte Clássico'), findsOneWidget);
    expect(find.text(r'R$ 45'), findsOneWidget);
    expect(find.text('45 min'), findsOneWidget);

    await tester.tap(find.byTooltip('Editar').first);
    await tester.pumpAndSettle();

    expect(find.text('EDITAR SERVIÇO'), findsOneWidget);
    // Na lista e no campo NOME do formulário.
    expect(find.text('Corte Clássico'), findsNWidgets(2));
    expect(find.text('SALVAR ALTERAÇÕES'), findsOneWidget);

    await tester.ensureVisible(find.text('CANCELAR EDIÇÃO'));
    await tester.tap(find.text('CANCELAR EDIÇÃO'));
    await tester.pumpAndSettle();
    expect(find.text('NOVO SERVIÇO'), findsOneWidget);
  });

  testWidgets('adicionar serviço grava no banco e recarrega a lista',
      (tester) async {
    final api = ApiFalsa();
    var recarregou = 0;

    await http.runWithClient(() async {
      await abrirAbaServicos(tester, onAlterado: () async => recarregou++);

      final campos = find.byType(TextFormField);
      await tester.enterText(campos.at(0), 'Pigmentação');
      await tester.enterText(campos.at(1), '47,5');
      await tester.enterText(campos.at(2), '40');
      await tester.ensureVisible(find.text('ADICIONAR SERVIÇO'));
      await tester.tap(find.text('ADICIONAR SERVIÇO'));
      await tester.pumpAndSettle();
    }, api.cliente);

    expect(find.text('"Pigmentação" foi adicionado.'), findsOneWidget);
    expect(recarregou, 1);

    final post = api.requisicoes.single;
    expect(post.method, 'POST');
    expect(jsonDecode(post.body), {
      'ID': 0,
      'NameServico': 'Pigmentação',
      'Preco': 47.5,
      'DuracaoMinutos': 40,
    });
  });
}
