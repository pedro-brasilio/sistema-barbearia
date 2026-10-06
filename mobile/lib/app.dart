import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'api.dart';
import 'models.dart';
import 'pages/admin_page.dart';
import 'pages/booking_page.dart';
import 'pages/home_page.dart';
import 'pages/login_page.dart';
import 'pages/perfil_page.dart';
import 'theme.dart';
import 'widgets/header.dart';

class BarbershopApp extends StatelessWidget {
  const BarbershopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Barbershop',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppShell(),
    );
  }
}

/// Equivalente ao componente App do App.tsx: guarda a tela atual,
/// o usuário logado e a lista de agendamentos carregada da API.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppView _view = AppView.home;
  AppUser? _user;
  List<Appointment> _appointments = [];

  void _setView(AppView view) {
    setState(() => _view = view);
    // Recarrega a cada troca de tela, para mostrar também
    // agendamentos feitos pelo site ou em outro aparelho.
    _carregarAgendamentos();
  }

  /// Busca os agendamentos no banco: todos para o admin, só os do cliente para os demais.
  Future<void> _carregarAgendamentos() async {
    final user = _user;
    if (user == null) return;
    try {
      final dados = user.isAdmin
          ? await Api.listarAgendamentos()
          : await Api.listarAgendamentosCliente(user.id);
      // Descarta a resposta se o usuário saiu enquanto carregava.
      if (!mounted || _user != user) return;
      setState(() {
        _appointments = [
          for (final json in dados as List)
            if (json['situacao'] != 'cancelado')
              Appointment.fromApi(json as Map<String, dynamic>, user),
        ];
      });
    } on ApiException catch (err) {
      debugPrint(err.message);
    }
  }

  void _mostrarErro(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _handleNavigate(AppView target) {
    if (target == AppView.login && _user != null) {
      _setView(AppView.perfil);
      return;
    }
    _setView(target);
  }

  Future<void> _handleUpdateStatus(String id, AppointmentStatus status) async {
    if (status != AppointmentStatus.confirmed) return; // a API só permite confirmar
    try {
      await Api.confirmarAgendamento(int.parse(id));
    } on ApiException catch (err) {
      _mostrarErro(err.message);
    }
    await _carregarAgendamentos();
  }

  Future<void> _handleDeleteAppointment(String id) async {
    try {
      await Api.deletarAgendamento(int.parse(id));
    } on ApiException catch (err) {
      _mostrarErro(err.message);
    }
    await _carregarAgendamentos();
  }

  void _handleLogout() {
    setState(() {
      _user = null;
      _appointments = [];
      _view = AppView.home;
    });
  }

  Widget _buildPage() {
    final user = _user;
    switch (_view) {
      case AppView.home:
        return HomePage(
          onNavigateToBooking: () => _setView(AppView.booking),
        );
      case AppView.login:
        return LoginPage(
          onNavigateBack: () => _setView(AppView.home),
          onLoginSuccess: (userData) {
            setState(() {
              _user = userData;
              _view = AppView.home;
            });
            _carregarAgendamentos();
          },
        );
      case AppView.booking:
        return BookingPage(
          user: user,
          appointments: _appointments,
          onAddAppointment: _carregarAgendamentos,
          onNavigateToLogin: () => _setView(AppView.login),
        );
      case AppView.admin:
        return AdminPage(
          appointments: _appointments,
          isAdmin: user?.isAdmin ?? false,
          onUpdateStatus: _handleUpdateStatus,
          onDeleteAppointment: _handleDeleteAppointment,
        );
      case AppView.perfil:
        if (user == null) return const SizedBox.shrink();
        return PerfilPage(
          user: user,
          appointments: _appointments,
          onNavigateBack: () => _setView(AppView.home),
          onLogout: _handleLogout,
          onCancelAppointment: _handleDeleteAppointment,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.backgroundAlt,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      // Botão "voltar" do Android: volta para o início antes de fechar o app.
      child: PopScope(
        canPop: _view == AppView.home,
        onPopInvokedWithResult: (didPop, result) {
          if (!didPop) _setView(AppView.home);
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Column(
            children: [
              AppHeader(onLogoTap: () => _handleNavigate(AppView.home)),
              Expanded(
                child: KeyedSubtree(
                  key: ValueKey(_view),
                  child: _buildPage(),
                ),
              ),
            ],
          ),
          bottomNavigationBar: AppBottomNav(
            currentView: _view,
            user: _user,
            onNavigate: _handleNavigate,
          ),
        ),
      ),
    );
  }
}
