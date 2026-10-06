import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../api.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/dates.dart';
import '../widgets/common.dart';

/// Versão mobile do pages/BookingForm.tsx.
/// No celular o grid vira uma coluna: formulário e depois "MEUS AGENDAMENTOS".
class BookingPage extends StatefulWidget {
  const BookingPage({
    super.key,
    required this.user,
    required this.appointments,
    required this.onAddAppointment,
    required this.onNavigateToLogin,
  });

  final AppUser? user;
  final List<Appointment> appointments;
  final VoidCallback onAddAppointment; // recarrega a lista depois de agendar
  final VoidCallback onNavigateToLogin;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  String _service = '';
  String _date = '';
  String _time = '';

  bool _showSuccess = false;
  String _erro = '';
  bool _loading = false;
  Timer? _successTimer;

  static const _services = [
    (name: 'Corte Clássico', price: r'R$ 45'),
    (name: 'Corte + Barba', price: r'R$ 70'),
    (name: 'Barba Tradicional', price: r'R$ 35'),
    (name: 'Corte Premium', price: r'R$ 80'),
  ];

  static const _timeSlots = [
    '09:00', '09:30', //
    '10:00', '10:30',
    '11:00', '11:30',
    '14:00', '14:30',
    '15:00', '15:30',
    '16:00', '16:30',
    '17:00', '17:30',
    '18:00', '18:30',
    '19:00',
  ];

  @override
  void dispose() {
    _successTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final user = widget.user;
    if (user == null) return;

    setState(() => _erro = '');

    if (_service.isEmpty) {
      setState(() => _erro = 'Selecione um serviço.');
      return;
    }
    if (_date.isEmpty) {
      setState(() => _erro = 'Selecione uma data.');
      return;
    }
    if (_time.isEmpty) {
      setState(() => _erro = 'Selecione um horário.');
      return;
    }

    setState(() => _loading = true);

    try {
      await Api.criarAgendamento(
        clienteId: user.id,
        barbeiroId: 1,
        servicos: _service,
        data: _date,
        dataHoraInicio: _time,
        situacao: 'pendente',
      );

      widget.onAddAppointment();

      if (!mounted) return;
      setState(() {
        _service = '';
        _date = '';
        _time = '';
        _showSuccess = true;
      });
      _successTimer?.cancel();
      _successTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) setState(() => _showSuccess = false);
      });
    } catch (err) {
      final message = err is ApiException ? err.message : err.toString();
      if (mounted) {
        setState(() => _erro =
            message.isNotEmpty ? message : 'Erro ao realizar agendamento.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;

    // Agendamentos do usuário logado.
    final userAppointments = user == null
        ? <Appointment>[]
        : widget.appointments
            .where((apt) =>
                apt.clientName.toLowerCase() == user.name.toLowerCase())
            .toList();

    return ColoredBox(
      color: AppColors.page,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const FadeSlideIn(
              child: PageTitle('AGENDE SEU HORÁRIO', size: 42),
            ),
            const SizedBox(height: 32),
            FadeSlideIn(
              offset: const Offset(-30, 0),
              delay: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (user == null) _buildLocked() else _buildForm(user),
                  if (_showSuccess)
                    FadeSlideIn(
                      child: Container(
                        margin: const EdgeInsets.only(top: 24),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.primary20,
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: Text(
                          '✓ Agendamento realizado com sucesso!',
                          textAlign: TextAlign.center,
                          style: AppText.body(
                            16,
                            color: AppColors.primary,
                            weight: FontWeight.w600,
                            letterSpacing: 0.64,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FadeSlideIn(
              offset: const Offset(30, 0),
              delay: const Duration(milliseconds: 300),
              child: _buildSidebar(user, userAppointments),
            ),
          ],
        ),
      ),
    );
  }

  // BLOQUEIO SE NÃO LOGADO
  Widget _buildLocked() {
    return PanelCard(
      padding: const EdgeInsets.all(20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 260),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.logIn, size: 48, color: AppColors.primary60),
            const SizedBox(height: 16),
            Text(
              'FAÇA LOGIN PARA AGENDAR',
              textAlign: TextAlign.center,
              style: AppText.display(28, letterSpacing: 1.4),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                'Você precisa estar logado para realizar um agendamento.',
                textAlign: TextAlign.center,
                style: AppText.body(15, color: AppColors.gray77),
              ),
            ),
            const SizedBox(height: 16),
            GoldButton(
              label: 'IR PARA O LOGIN',
              icon: LucideIcons.logIn,
              onPressed: widget.onNavigateToLogin,
              expand: false,
              padding: const EdgeInsets.symmetric(horizontal: 40),
              textStyle: AppText.body(
                18,
                weight: FontWeight.w700,
                letterSpacing: 2.16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // CARD 1 — DADOS DO USUÁRIO LOGADO
        PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CardTitle(icon: LucideIcons.user, text: 'DADOS PESSOAIS'),
              const FieldLabel('NOME COMPLETO'),
              _ReadOnlyBox(value: user.name),
              const SizedBox(height: 24),
              const FieldLabel('TELEFONE'),
              _ReadOnlyBox(value: user.telefone),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // CARD 2 — SERVIÇO
        PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CardTitle(text: 'SERVIÇO'),
              for (var i = 0; i < _services.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                _ServiceOption(
                  name: _services[i].name,
                  price: _services[i].price,
                  selected: _service == _services[i].name,
                  onTap: () => setState(() => _service = _services[i].name),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),

        // CARD 3 — DATA E HORÁRIO
        PanelCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const _CardTitle(
                icon: LucideIcons.calendar,
                text: 'DATA E HORÁRIO',
              ),
              const FieldLabel('DATA'),
              Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 360),
                  child: DateBoxField(
                    value: _date,
                    firstDate: parseIsoDate(todayIso()),
                    onChanged: (value) => setState(() => _date = value),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IconText(
                  icon: LucideIcons.clock,
                  text: 'HORÁRIO DISPONÍVEL',
                  iconSize: 16,
                  style: AppText.body(
                    14,
                    color: AppColors.gray7a,
                    weight: FontWeight.w500,
                    letterSpacing: 0.56,
                  ),
                ),
              ),
              _TimeGrid(
                slots: _timeSlots,
                selected: _time,
                onSelect: (time) => setState(() => _time = time),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ERRO
        if (_erro.isNotEmpty) ...[
          MessageBox.error(_erro),
          const SizedBox(height: 24),
        ],

        // BOTÃO
        GoldButton(
          label: _loading ? 'AGUARDE...' : 'CONFIRMAR AGENDAMENTO',
          icon: LucideIcons.check,
          iconSize: 20,
          onPressed: _loading ? null : _handleSubmit,
          textStyle: AppText.body(
            18,
            weight: FontWeight.w700,
            letterSpacing: 2.16,
          ),
        ),
      ],
    );
  }

  // SIDEBAR — MEUS AGENDAMENTOS
  Widget _buildSidebar(AppUser? user, List<Appointment> userAppointments) {
    Widget content;
    if (user == null) {
      content = const _EmptyText('Faça login para ver seus agendamentos.');
    } else if (userAppointments.isEmpty) {
      content = const _EmptyText('Nenhum agendamento encontrado.');
    } else {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < userAppointments.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _AppointmentCard(appointment: userAppointments[i]),
          ],
        ],
      );
    }

    return PanelCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'MEUS AGENDAMENTOS',
            textAlign: TextAlign.center,
            style: AppText.body(
              24,
              color: AppColors.text,
              weight: FontWeight.w600,
              letterSpacing: 0.96,
            ),
          ),
          const SizedBox(height: 16),
          content,
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final iconData = icon;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        children: [
          if (iconData != null) ...[
            Icon(iconData, size: 20, color: AppColors.primary),
            const SizedBox(width: 10),
          ],
          Flexible(
            child: Text(
              text,
              style: AppText.body(
                24,
                color: AppColors.text,
                weight: FontWeight.w600,
                letterSpacing: 0.96,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Input somente leitura (booking-input-readonly: opacidade 0.6).
class _ReadOnlyBox extends StatelessWidget {
  const _ReadOnlyBox({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.6,
      child: Container(
        height: 52,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.input,
          border: Border.all(color: AppColors.primary20),
        ),
        child: Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppText.body(16, color: AppColors.text),
        ),
      ),
    );
  }
}

class _ServiceOption extends StatelessWidget {
  const _ServiceOption({
    required this.name,
    required this.price,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String price;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary10 : AppColors.input,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.primary20,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: AppText.body(
                  18,
                  color: selected ? AppColors.primary : AppColors.text,
                  weight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              price,
              style: AppText.display(30, letterSpacing: 1.5, height: 1.1),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grade de horários. No site, abaixo de 768px ela tem 4 colunas.
class _TimeGrid extends StatelessWidget {
  const _TimeGrid({
    required this.slots,
    required this.selected,
    required this.onSelect,
  });

  final List<String> slots;
  final String selected;
  final ValueChanged<String> onSelect;

  static const _columns = 4;
  static const _gap = 8.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - _gap * (_columns - 1)) / _columns;
        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (final time in slots)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSelect(time),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: width,
                  height: 42,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color:
                        selected == time ? AppColors.primary : AppColors.input,
                    border: Border.all(
                      color: selected == time
                          ? AppColors.primary
                          : AppColors.primary20,
                    ),
                  ),
                  child: Text(
                    time,
                    style: AppText.body(
                      14,
                      color: selected == time ? AppColors.page : AppColors.text,
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    // Centralizado, como o título do card
    return Text(
      text,
      textAlign: TextAlign.center,
      style: AppText.body(15, color: AppColors.gray77, height: 1.5),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final Appointment appointment;

  @override
  Widget build(BuildContext context) {
    final confirmed = appointment.status == AppointmentStatus.confirmed;
    final detailStyle = AppText.body(14, color: AppColors.gray7a);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.input,
        border: Border.all(color: AppColors.primary20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  appointment.service,
                  style: AppText.body(
                    14,
                    color: AppColors.primary,
                    weight: FontWeight.w600,
                    letterSpacing: 0.56,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                color: confirmed ? AppColors.primary20 : AppColors.white5,
                child: Text(
                  confirmed ? 'CONFIRMADO' : 'PENDENTE',
                  style: AppText.body(
                    12,
                    color: confirmed ? AppColors.primary : AppColors.gray77,
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          IconText(
            icon: LucideIcons.calendar,
            text: formatDateBr(appointment.date),
            iconSize: 12,
            style: detailStyle,
          ),
          const SizedBox(height: 4),
          IconText(
            icon: LucideIcons.clock,
            text: appointment.time,
            iconSize: 12,
            style: detailStyle,
          ),
        ],
      ),
    );
  }
}
