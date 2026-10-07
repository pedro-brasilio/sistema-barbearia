import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:barbershop_mobile/models.dart';
import 'package:barbershop_mobile/pages/perfil_page.dart';
import 'package:barbershop_mobile/theme.dart';
import 'package:barbershop_mobile/utils/dates.dart';

void main() {
  final agora = DateTime.now();
  final hoje = isoDate(agora);
  final ontem = isoDate(DateTime(agora.year, agora.month, agora.day - 1));
  final amanha = isoDate(DateTime(agora.year, agora.month, agora.day + 1));

  Appointment agendamento(String id, String cliente, String data) =>
      Appointment(
        id: id,
        clientName: cliente,
        phone: '(11) 9999-000$id',
        service: 'Corte Clássico',
        date: data,
        time: '10:00',
        status: AppointmentStatus.pending,
      );

  final agenda = [
    agendamento('1', 'Ana', amanha),
    agendamento('2', 'Bruno', hoje),
    agendamento('3', 'Carla', ontem),
  ];

  Future<void> abrirPerfil(WidgetTester tester, AppUser user) async {
    tester.view.physicalSize = const Size(1080, 4000);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(
        body: PerfilPage(
          user: user,
          appointments: agenda,
          onNavigateBack: () {},
          onLogout: () {},
          onCancelAppointment: (_) {},
        ),
      ),
    ));
    await tester.pumpAndSettle();
  }

  double alturaDe(WidgetTester tester, Finder finder) =>
      tester.getTopLeft(finder).dy;

  testWidgets('admin vê os próximos dias e o histórico só de hoje',
      (tester) async {
    await abrirPerfil(
      tester,
      const AppUser(
        id: 1,
        name: 'Administrador',
        email: 'admin@barbearia.com',
        telefone: '',
        isAdmin: true,
      ),
    );

    final historico = find.text(
      'HISTÓRICO DO DIA · ${hoje.substring(8, 10)}/${hoje.substring(5, 7)}',
    );
    expect(historico, findsOneWidget);

    // Amanhã fica em PRÓXIMOS, hoje no histórico do dia e ontem some.
    final ana = find.textContaining('Ana ·');
    final bruno = find.textContaining('Bruno ·');
    expect(ana, findsOneWidget);
    expect(bruno, findsOneWidget);
    expect(find.textContaining('Carla'), findsNothing);
    expect(alturaDe(tester, ana), lessThan(alturaDe(tester, historico)));
    expect(alturaDe(tester, bruno), greaterThan(alturaDe(tester, historico)));
  });

  testWidgets('cliente continua vendo só os próprios agendamentos',
      (tester) async {
    await abrirPerfil(
      tester,
      const AppUser(
        id: 2,
        name: 'Carla',
        email: 'carla@email.com',
        telefone: '',
        isAdmin: false,
      ),
    );

    expect(find.text('HISTÓRICO'), findsOneWidget);
    expect(find.text('Nenhum agendamento próximo.'), findsOneWidget);
    // O agendamento de ontem da Carla, sem o nome (o cliente é ela mesma).
    expect(find.text('CANCELADO'), findsOneWidget);
    expect(find.textContaining('Ana'), findsNothing);
  });
}
