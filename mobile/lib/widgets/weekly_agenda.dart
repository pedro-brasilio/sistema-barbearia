import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../api.dart';
import '../models.dart';
import '../theme.dart';
import '../utils/dates.dart';
import 'common.dart';

/// Consulta a agenda mantida no banco; não reconstrói a agenda a partir da lista local.
class WeeklyAgenda extends StatefulWidget {
  const WeeklyAgenda({
    super.key,
    required this.revision,
    required this.onUpdateStatus,
    required this.onDeleteAppointment,
    this.initialDate,
  });

  final Object revision;
  final FutureOr<void> Function(String id, AppointmentStatus status)
  onUpdateStatus;
  final FutureOr<void> Function(String id) onDeleteAppointment;
  final String? initialDate;

  @override
  State<WeeklyAgenda> createState() => _WeeklyAgendaState();
}

class _WeeklyAgendaState extends State<WeeklyAgenda> {
  late String _data;
  String? _inicio;
  String? _fim;
  List<Appointment> _appointments = [];
  String? _erro;
  bool _loading = true;
  bool _busy = false;
  int _request = 0;

  @override
  void initState() {
    super.initState();
    _data = weekStartIso(widget.initialDate ?? todayIso());
    _load();
  }

  @override
  void didUpdateWidget(covariant WeeklyAgenda oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revision != widget.revision) _load();
  }

  @override
  void dispose() {
    _request++;
    super.dispose();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      final data = await Api.listarAgendaSemanal(_data) as Map<String, dynamic>;
      if (!mounted || request != _request) return;
      setState(() {
        _inicio = data['inicioSemana'] as String;
        _fim = data['fimSemana'] as String;
        _appointments = [
          for (final item in data['agendamentos'] as List)
            Appointment.fromApi(item as Map<String, dynamic>),
        ];
        _loading = false;
      });
    } catch (error) {
      if (!mounted || request != _request) return;
      setState(() {
        _appointments = [];
        _inicio = null;
        _fim = null;
        _loading = false;
        _erro = error is ApiException
            ? error.message
            : 'Não foi possível carregar a agenda semanal.';
      });
    }
  }

  void _changeDate(String value) {
    if (value.isEmpty) return;
    _data = weekStartIso(value);
    _inicio = null;
    _fim = null;
    _appointments = [];
    _load();
  }

  Future<void> _changeAppointment(Appointment item, bool confirm) async {
    setState(() {
      _busy = true;
      _erro = null;
    });
    try {
      if (confirm) {
        await widget.onUpdateStatus(item.id, AppointmentStatus.confirmed);
      } else {
        await widget.onDeleteAppointment(item.id);
      }
      if (mounted) await _load();
    } catch (error) {
      if (mounted) {
        setState(() => _erro = error is ApiException
            ? error.message
            : 'Não foi possível alterar o agendamento.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final inicio = _inicio ?? weekStartIso(_data);
    final fim = _fim ?? shiftIsoDays(inicio, 6);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PanelCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: 'Semana anterior',
                    onPressed: () => _changeDate(shiftIsoDays(_data, -7)),
                    icon: const Icon(
                      LucideIcons.chevronLeft,
                      color: AppColors.primary,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'SEMANA',
                      textAlign: TextAlign.center,
                      style: AppText.body(18, weight: FontWeight.w600),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Próxima semana',
                    onPressed: () => _changeDate(shiftIsoDays(_data, 7)),
                    icon: const Icon(
                      LucideIcons.chevronRight,
                      color: AppColors.primary,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Atualizar agenda semanal',
                    onPressed: _load,
                    icon: const Icon(
                      LucideIcons.refreshCw,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DateBoxField(value: _data, onChanged: _changeDate),
              const SizedBox(height: 12),
              Text(
                '${formatDateBr(inicio)} a ${formatDateBr(fim)}',
                style: AppText.body(16, color: AppColors.grayD4),
              ),
              Text(
                'Segunda-feira a domingo',
                style: AppText.body(14, color: AppColors.gray9c),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_erro != null) ...[
          MessageBox.error(_erro!),
          const SizedBox(height: 16),
        ],
        if (_loading)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          )
        else if (_erro == null && _appointments.isEmpty)
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Nenhum agendamento nesta semana.',
              style: AppText.body(16, color: AppColors.gray9c),
            ),
          )
        else
          for (final item in _appointments)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: PanelCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${formatDateBr(item.date)} · ${item.time}',
                      style: AppText.body(
                        17,
                        color: AppColors.primary,
                        weight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.clientName,
                      style: AppText.body(18, weight: FontWeight.w600),
                    ),
                    if (item.phone.isNotEmpty)
                      Text(
                        item.phone,
                        style: AppText.body(15, color: AppColors.gray9c),
                      ),
                    Text(
                      item.service,
                      style: AppText.body(16, color: AppColors.grayD4),
                    ),
                    Text(
                      item.status == AppointmentStatus.confirmed
                          ? 'CONFIRMADO'
                          : 'PENDENTE',
                      style: AppText.body(14, color: AppColors.primary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        if (item.status == AppointmentStatus.pending)
                          TextButton(
                            onPressed: _busy
                                ? null
                                : () => _changeAppointment(item, true),
                            child: const Text('CONFIRMAR'),
                          ),
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _changeAppointment(item, false),
                          child: const Text('REMOVER'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}
