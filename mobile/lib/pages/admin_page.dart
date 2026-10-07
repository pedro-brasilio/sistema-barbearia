import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models.dart';
import '../theme.dart';
import '../utils/dates.dart';
import '../widgets/common.dart';
import '../widgets/notification_sender.dart';
import '../widgets/services_manager.dart';

/// Filtro de status do select (all / confirmed / pending).
enum StatusFilter { all, confirmed, pending }

/// Abas do painel do administrador.
enum AdminTab { agendamentos, servicos, notificacoes }

/// Versão mobile do pages/AdminPanel.tsx.
/// A tabela vira uma lista de linhas empilhadas, com os mesmos dados e ações.
class AdminPage extends StatefulWidget {
  const AdminPage({
    super.key,
    required this.appointments,
    required this.isAdmin,
    this.servicos,
    this.onServicosAlterados,
    required this.onUpdateStatus,
    required this.onDeleteAppointment,
  });

  final List<Appointment> appointments;
  final bool isAdmin;

  /// Serviços do banco (null enquanto carrega) e como recarregá-los.
  final List<Servico>? servicos;
  final Future<void> Function()? onServicosAlterados;
  final void Function(String id, AppointmentStatus status) onUpdateStatus;
  final ValueChanged<String> onDeleteAppointment;

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  String _search = '';
  StatusFilter _statusFilter = StatusFilter.all;
  String _dateFilter = '';
  AdminTab _tab = AdminTab.agendamentos;

  bool _matchStatus(Appointment apt) {
    switch (_statusFilter) {
      case StatusFilter.all:
        return true;
      case StatusFilter.confirmed:
        return apt.status == AppointmentStatus.confirmed;
      case StatusFilter.pending:
        return apt.status == AppointmentStatus.pending;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appointments = widget.appointments;
    final total = appointments.length;
    final today = todayIso();
    final todayCount = appointments.where((a) => a.date == today).length;
    final confirmed = appointments
        .where((a) => a.status == AppointmentStatus.confirmed)
        .length;
    final pending =
        appointments.where((a) => a.status == AppointmentStatus.pending).length;

    final filtered = appointments.where((apt) {
      final matchSearch =
          apt.clientName.toLowerCase().contains(_search.toLowerCase()) ||
              apt.phone.contains(_search);
      final matchDate = _dateFilter.isEmpty || apt.date == _dateFilter;
      return matchSearch && _matchStatus(apt) && matchDate;
    }).toList();

    final metrics = [
      (value: total, label: 'TOTAL DE AGENDAMENTOS'),
      (value: todayCount, label: 'AGENDAMENTOS HOJE'),
      (value: confirmed, label: 'CONFIRMADOS'),
      (value: pending, label: 'PENDENTES'),
    ];

    return ColoredBox(
      color: AppColors.page,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // TÍTULO
            FadeSlideIn(
              child: PageTitle(
                switch (_tab) {
                  AdminTab.agendamentos => 'PAINEL DE AGENDAMENTOS',
                  AdminTab.servicos => 'SERVIÇOS',
                  AdminTab.notificacoes => 'NOTIFICAÇÕES',
                },
                size: 40,
              ),
            ),
            const SizedBox(height: 24),

            // ABAS (só para o administrador)
            if (widget.isAdmin) ...[
              _AdminTabs(
                current: _tab,
                onChanged: (tab) => setState(() => _tab = tab),
              ),
              const SizedBox(height: 24),
            ],

            if (widget.isAdmin && _tab == AdminTab.notificacoes)
              const FadeSlideIn(
                delay: Duration(milliseconds: 100),
                child: NotificationSender(),
              )
            else if (widget.isAdmin && _tab == AdminTab.servicos)
              ServicesManager(
                servicos: widget.servicos,
                onAlterado: widget.onServicosAlterados ?? () async {},
              )
            else ...[
              // MÉTRICAS (2 colunas no celular)
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: Column(
                  children: [
                    for (var row = 0; row < 2; row++) ...[
                      if (row > 0) const SizedBox(height: 16),
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var col = 0; col < 2; col++) ...[
                              if (col > 0) const SizedBox(width: 16),
                              Expanded(
                                child: _MetricCard(
                                  value: metrics[row * 2 + col].value,
                                  label: metrics[row * 2 + col].label,
                                  highlight: row * 2 + col == 1,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // FILTROS
              FadeSlideIn(
                delay: const Duration(milliseconds: 200),
                child: PanelCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          children: [
                            const Icon(
                              LucideIcons.funnel,
                              size: 18,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'FILTROS',
                              style: AppText.body(
                                20,
                                color: AppColors.text,
                                weight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      BoxInput(
                        hint: 'Buscar por nome ou telefone...',
                        icon: LucideIcons.search,
                        iconSize: 16,
                        iconColor: AppColors.gray6f,
                        iconLeft: 14,
                        paddingLeft: 42,
                        height: 48,
                        textStyle: AppText.body(15, color: AppColors.text),
                        hintStyle: AppText.body(15, color: AppColors.gray6f),
                        onChanged: (value) => setState(() => _search = value),
                      ),
                      const SizedBox(height: 16),
                      SelectBox<StatusFilter>(
                        value: _statusFilter,
                        items: const [
                          (StatusFilter.all, 'Todos os Status'),
                          (StatusFilter.confirmed, 'Confirmado'),
                          (StatusFilter.pending, 'Pendente'),
                        ],
                        onChanged: (value) =>
                            setState(() => _statusFilter = value),
                      ),
                      const SizedBox(height: 16),
                      DateBoxField(
                        value: _dateFilter,
                        height: 48,
                        fontSize: 15,
                        clearable: true,
                        onChanged: (value) =>
                            setState(() => _dateFilter = value),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // LISTA (tabela no site)
              FadeSlideIn(
                delay: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    border: Border.all(color: AppColors.primary20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (filtered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(48),
                          child: Text(
                            'Nenhum agendamento encontrado',
                            textAlign: TextAlign.center,
                            style: AppText.body(
                              15,
                              color: AppColors.gray55,
                              letterSpacing: 0.6,
                            ),
                          ),
                        )
                      else
                        for (var i = 0; i < filtered.length; i++)
                          _AppointmentRow(
                            appointment: filtered[i],
                            isAdmin: widget.isAdmin,
                            showDivider: i < filtered.length - 1,
                            onConfirm: () => widget.onUpdateStatus(
                              filtered[i].id,
                              AppointmentStatus.confirmed,
                            ),
                            onDelete: () =>
                                widget.onDeleteAppointment(filtered[i].id),
                          ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 14,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            top: BorderSide(color: AppColors.primary10),
                          ),
                        ),
                        child: Text(
                          'Exibindo ${filtered.length} de $total agendamentos',
                          textAlign: TextAlign.center,
                          style: AppText.body(
                            14,
                            color: AppColors.gray55,
                            letterSpacing: 0.56,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Abas AGENDAMENTOS / SERVIÇOS / NOTIFICAÇÕES, um terço da largura cada,
/// com o ícone em cima do texto.
class _AdminTabs extends StatelessWidget {
  const _AdminTabs({required this.current, required this.onChanged});

  final AdminTab current;
  final ValueChanged<AdminTab> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget tab(AdminTab value, IconData icon, String label) {
      final active = current == value;
      final color = active ? AppColors.primary : AppColors.gray7a;
      return Expanded(
        child: BoxButton(
          onPressed: () => onChanged(value),
          height: 60,
          background: active ? AppColors.primary15 : Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                style: AppText.body(
                  12,
                  color: color,
                  weight: FontWeight.w600,
                  letterSpacing: 0.72,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.primary20),
      ),
      child: Row(
        children: [
          tab(AdminTab.agendamentos, LucideIcons.calendar, 'AGENDAMENTOS'),
          tab(AdminTab.servicos, LucideIcons.scissors, 'SERVIÇOS'),
          tab(AdminTab.notificacoes, LucideIcons.bell, 'NOTIFICAÇÕES'),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.value,
    required this.label,
    required this.highlight,
  });

  final int value;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(
          color: highlight ? AppColors.primary : AppColors.primary20,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$value',
            style: AppText.display(48, letterSpacing: 0.96, height: 1),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: AppText.body(
              13,
              color: AppColors.gray7a,
              weight: FontWeight.w500,
              letterSpacing: 1.04,
            ),
          ),
        ],
      ),
    );
  }
}

/// Uma linha da tabela: CLIENTE, TELEFONE, SERVIÇO, DATA, HORÁRIO, STATUS, AÇÕES.
class _AppointmentRow extends StatelessWidget {
  const _AppointmentRow({
    required this.appointment,
    required this.isAdmin,
    required this.showDivider,
    required this.onConfirm,
    required this.onDelete,
  });

  final Appointment appointment;
  final bool isAdmin;
  final bool showDivider;
  final VoidCallback onConfirm;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final cellStyle = AppText.body(15, color: AppColors.grayD4);
    final isPending = appointment.status == AppointmentStatus.pending;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.white4))
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconText(
                  icon: LucideIcons.user,
                  text: appointment.clientName,
                  iconColor: AppColors.primary,
                  style: cellStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                IconText(
                  icon: LucideIcons.phone,
                  text: appointment.phone,
                  iconColor: AppColors.primary,
                  style: cellStyle,
                ),
                const SizedBox(height: 8),
                Text(appointment.service, style: cellStyle),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    IconText(
                      icon: LucideIcons.calendar,
                      text: formatDateAdmin(appointment.date),
                      iconColor: AppColors.primary,
                      style: cellStyle,
                    ),
                    IconText(
                      icon: LucideIcons.clock,
                      text: appointment.time,
                      iconColor: AppColors.primary,
                      style: cellStyle,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _StatusBadge(confirmed: !isPending),
              if (isAdmin) ...[
                const SizedBox(height: 12),
                isPending
                    ? _ActionButton(
                        icon: LucideIcons.check,
                        tooltip: 'Confirmar',
                        background: AppColors.primary15,
                        borderColor: AppColors.primary40,
                        color: AppColors.primary,
                        pressedBackground: AppColors.primary,
                        pressedColor: AppColors.page,
                        onPressed: onConfirm,
                      )
                    : _ActionButton(
                        icon: LucideIcons.x,
                        tooltip: 'Remover',
                        background: AppColors.white4,
                        borderColor: AppColors.white12,
                        color: AppColors.gray88,
                        pressedBackground: AppColors.danger20,
                        pressedColor: AppColors.danger,
                        onPressed: onDelete,
                      ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.confirmed});

  final bool confirmed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: confirmed ? AppColors.primary15 : AppColors.white5,
        border: Border.all(
          color: confirmed ? AppColors.primary40 : AppColors.white10,
        ),
      ),
      child: Text(
        confirmed ? 'CONFIRMADO' : 'PENDENTE',
        style: AppText.body(
          12,
          color: confirmed ? AppColors.primary : AppColors.gray88,
          weight: FontWeight.w700,
          letterSpacing: 0.72,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.background,
    required this.borderColor,
    required this.color,
    required this.pressedBackground,
    required this.pressedColor,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final Color background;
  final Color borderColor;
  final Color color;
  final Color pressedBackground;
  final Color pressedColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: BoxButton(
        onPressed: onPressed,
        width: 40,
        height: 40,
        background: background,
        pressedBackground: pressedBackground,
        foreground: color,
        pressedForeground: pressedColor,
        borderColor: borderColor,
        child: Icon(icon, size: 16),
      ),
    );
  }
}
