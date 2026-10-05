import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models.dart';
import '../theme.dart';
import '../utils/dates.dart';
import '../widgets/common.dart';

/// Versão mobile do pages/Perfil.tsx.
class PerfilPage extends StatefulWidget {
  const PerfilPage({
    super.key,
    required this.user,
    required this.appointments,
    required this.onNavigateBack,
    required this.onLogout,
    required this.onCancelAppointment,
  });

  final AppUser user;
  final List<Appointment> appointments;
  final VoidCallback onNavigateBack;
  final VoidCallback onLogout;
  final ValueChanged<String> onCancelAppointment;

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  final _formKey = GlobalKey<FormState>();
  bool _showPersonalInfo = false;
  bool _showPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;
  String _erro = '';
  String _sucesso = '';
  Timer? _successTimer;

  late final _nome = TextEditingController(text: widget.user.name);
  late final _email = TextEditingController(text: widget.user.email);
  late final _telefone = TextEditingController(text: widget.user.telefone);
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    _successTimer?.cancel();
    _nome.dispose();
    _email.dispose();
    _telefone.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  /// type="email": o navegador só valida o formato quando há texto.
  String? _emailValidator(String? value) {
    final email = (value ?? '').trim();
    if (email.isEmpty) return null;
    final at = email.indexOf('@');
    if (at <= 0 || at == email.length - 1) {
      return 'Insira um endereço de e-mail válido.';
    }
    return null;
  }

  void _handleSave() {
    if (!(_formKey.currentState?.validate() ?? true)) return;

    setState(() {
      _erro = '';
      _sucesso = '';
    });

    if (_newPassword.text.isNotEmpty) {
      if (_currentPassword.text.isEmpty) {
        setState(() =>
            _erro = 'Digite sua senha atual para confirmar a alteração.');
        return;
      }
      if (_newPassword.text != _confirmPassword.text) {
        setState(() => _erro = 'As novas senhas não coincidem.');
        return;
      }
    }

    setState(() => _sucesso = 'Informações atualizadas com sucesso!');
    _successTimer?.cancel();
    _successTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) setState(() => _sucesso = '');
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final today = todayIso();
    final userName = user.name.toLowerCase();

    final proximosAgendamentos = widget.appointments
        .where((a) =>
            a.clientName.toLowerCase() == userName &&
            a.date.compareTo(today) >= 0)
        .toList();

    final historicoAgendamentos = widget.appointments
        .where((a) =>
            a.clientName.toLowerCase() == userName &&
            a.date.compareTo(today) < 0)
        .toList();

    return ColoredBox(
      color: AppColors.page,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // VOLTAR
            Align(
              alignment: Alignment.centerLeft,
              child: BackLink(
                onPressed: widget.onNavigateBack,
                useBodyFont: true,
              ),
            ),
            const SizedBox(height: 8),

            // TÍTULO
            const PageTitle('MEU PERFIL', size: 56),
            const SizedBox(height: 24),

            // CARD DO USUÁRIO
            _buildUserCard(user),
            const SizedBox(height: 16),

            // INFORMAÇÕES PESSOAIS
            _buildPersonalInfo(),
            const SizedBox(height: 16),

            // MEUS AGENDAMENTOS
            _buildAppointments(proximosAgendamentos, historicoAgendamentos),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard(AppUser user) {
    final metaStyle = AppText.body(14, color: AppColors.gray77);
    return PanelCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.primary40, width: 2),
                ),
                child: const Icon(
                  LucideIcons.user,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: AppText.body(
                        26,
                        color: AppColors.text,
                        weight: FontWeight.w700,
                        letterSpacing: 1,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Atualiza enquanto o usuário digita, como no site.
                    ListenableBuilder(
                      listenable: Listenable.merge([_email, _telefone]),
                      builder: (context, _) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconText(
                            icon: LucideIcons.mail,
                            text: _email.text.isNotEmpty
                                ? _email.text
                                : 'email@exemplo.com',
                            iconColor: AppColors.primary,
                            style: metaStyle,
                          ),
                          const SizedBox(height: 6),
                          IconText(
                            icon: LucideIcons.phone,
                            text: _telefone.text.isNotEmpty
                                ? _telefone.text
                                : '(00) 00000-0000',
                            iconColor: AppColors.primary,
                            style: metaStyle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          DangerButton(
            label: 'SAIR',
            icon: LucideIcons.logOut,
            onPressed: widget.onLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    return PanelCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () =>
                  setState(() => _showPersonalInfo = !_showPersonalInfo),
              highlightColor: AppColors.primary4,
              splashColor: Colors.transparent,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                child: Row(
                  children: [
                    const Icon(
                      LucideIcons.user,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'INFORMAÇÕES PESSOAIS',
                        style: _sectionTitleStyle,
                      ),
                    ),
                    Icon(
                      _showPersonalInfo
                          ? LucideIcons.chevronUp
                          : LucideIcons.chevronDown,
                      size: 20,
                      color: AppColors.gray77,
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _showPersonalInfo
                ? FadeSlideIn(
                    offset: Offset.zero,
                    duration: const Duration(milliseconds: 300),
                    child: _buildPersonalForm(),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalForm() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_erro.isNotEmpty) ...[
              MessageBox.error(_erro, centered: false),
              const SizedBox(height: 8),
            ],
            if (_sucesso.isNotEmpty) ...[
              MessageBox.success(_sucesso),
              const SizedBox(height: 8),
            ],
            _field(
              label: 'NOME COMPLETO',
              controller: _nome,
              hint: 'Seu nome',
              icon: LucideIcons.user,
            ),
            const SizedBox(height: 16),
            _field(
              label: 'E-MAIL',
              controller: _email,
              hint: 'seu@email.com',
              icon: LucideIcons.mail,
              keyboardType: TextInputType.emailAddress,
              validator: _emailValidator,
            ),
            const SizedBox(height: 16),
            _field(
              label: 'TELEFONE',
              controller: _telefone,
              hint: '(11) 99999-9999',
              icon: LucideIcons.phone,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 20),

            // SENHAS
            Container(
              padding: const EdgeInsets.only(top: 20),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.white6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Text(
                      'ALTERAR SENHA',
                      style: AppText.body(
                        13,
                        color: AppColors.gray55,
                        weight: FontWeight.w600,
                        letterSpacing: 1.04,
                      ),
                    ),
                  ),
                  _field(
                    label: 'SENHA ATUAL',
                    controller: _currentPassword,
                    hint: '••••••••',
                    icon: LucideIcons.lock,
                    obscure: !_showPassword,
                    suffix: EyeToggle(
                      visible: _showPassword,
                      size: 14,
                      color: AppColors.gray55,
                      onToggle: () =>
                          setState(() => _showPassword = !_showPassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field(
                    label: 'NOVA SENHA',
                    controller: _newPassword,
                    hint: '••••••••',
                    icon: LucideIcons.lock,
                    obscure: !_showNewPassword,
                    suffix: EyeToggle(
                      visible: _showNewPassword,
                      size: 14,
                      color: AppColors.gray55,
                      onToggle: () =>
                          setState(() => _showNewPassword = !_showNewPassword),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _field(
                    label: 'CONFIRMAR NOVA SENHA',
                    controller: _confirmPassword,
                    hint: '••••••••',
                    icon: LucideIcons.lock,
                    obscure: !_showConfirmPassword,
                    suffix: EyeToggle(
                      visible: _showConfirmPassword,
                      size: 14,
                      color: AppColors.gray55,
                      onToggle: () => setState(
                          () => _showConfirmPassword = !_showConfirmPassword),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GoldButton(
              label: 'SALVAR ALTERAÇÕES',
              icon: LucideIcons.save,
              iconSize: 16,
              height: 50,
              onPressed: _handleSave,
              textStyle: AppText.body(
                15,
                weight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    FormFieldValidator<String>? validator,
    bool obscure = false,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FieldLabel(
          label,
          style: AppText.body(
            12,
            color: AppColors.gray7a,
            weight: FontWeight.w500,
            letterSpacing: 0.96,
          ),
        ),
        BoxInput(
          controller: controller,
          hint: hint,
          icon: icon,
          iconSize: 16,
          iconColor: AppColors.gray55,
          iconLeft: 14,
          paddingLeft: 44,
          paddingRight: 44,
          height: 48,
          textStyle: AppText.body(15, color: AppColors.text),
          hintStyle: AppText.body(15, color: AppColors.gray55),
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          suffix: suffix,
        ),
      ],
    );
  }

  TextStyle get _sectionTitleStyle => AppText.body(
        18,
        color: AppColors.text,
        weight: FontWeight.w600,
        letterSpacing: 1.08,
      );

  Widget _buildAppointments(
    List<Appointment> proximos,
    List<Appointment> historico,
  ) {
    return PanelCard(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.white6)),
            ),
            child: Row(
              children: [
                const Icon(
                  LucideIcons.calendar,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('MEUS AGENDAMENTOS', style: _sectionTitleStyle),
                ),
              ],
            ),
          ),

          // PRÓXIMOS
          _AppointmentsGroup(
            icon: LucideIcons.circleCheck,
            title: 'PRÓXIMOS',
            showDivider: true,
            emptyText: 'Nenhum agendamento próximo.',
            children: [
              for (final apt in proximos)
                _PerfilAppointmentCard(
                  appointment: apt,
                  statusLabel: apt.status == AppointmentStatus.confirmed
                      ? 'CONFIRMADO'
                      : 'PENDENTE',
                  onCancel: () => widget.onCancelAppointment(apt.id),
                ),
            ],
          ),

          // HISTÓRICO
          _AppointmentsGroup(
            icon: LucideIcons.circleAlert,
            title: 'HISTÓRICO',
            showDivider: false,
            emptyText: 'Nenhum agendamento no histórico.',
            children: [
              for (final apt in historico)
                Opacity(
                  opacity: 0.6,
                  child: _PerfilAppointmentCard(
                    appointment: apt,
                    statusLabel: apt.status == AppointmentStatus.confirmed
                        ? 'CONCLUÍDO'
                        : 'CANCELADO',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AppointmentsGroup extends StatelessWidget {
  const _AppointmentsGroup({
    required this.icon,
    required this.title,
    required this.showDivider,
    required this.emptyText,
    required this.children,
  });

  final IconData icon;
  final String title;
  final bool showDivider;
  final String emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.white4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: IconText(
              icon: icon,
              text: title,
              style: AppText.body(
                13,
                color: AppColors.primary,
                weight: FontWeight.w600,
                letterSpacing: 1.04,
              ),
            ),
          ),
          if (children.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                emptyText,
                textAlign: TextAlign.center,
                style: AppText.body(14, color: AppColors.gray55),
              ),
            )
          else
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: 10),
              children[i],
            ],
        ],
      ),
    );
  }
}

class _PerfilAppointmentCard extends StatelessWidget {
  const _PerfilAppointmentCard({
    required this.appointment,
    required this.statusLabel,
    this.onCancel,
  });

  final Appointment appointment;
  final String statusLabel;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final confirmed = appointment.status == AppointmentStatus.confirmed;
    final detailStyle = AppText.body(13, color: AppColors.gray77);
    final cancel = onCancel;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.input,
        border: Border.all(color: AppColors.primary15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            appointment.service,
            style: AppText.body(
              16,
              color: AppColors.primary,
              weight: FontWeight.w600,
              letterSpacing: 0.64,
            ),
          ),
          const SizedBox(height: 8),
          IconText(
            icon: LucideIcons.calendar,
            text: formatDateLong(appointment.date),
            iconSize: 12,
            gap: 6,
            style: detailStyle,
          ),
          const SizedBox(height: 4),
          IconText(
            icon: LucideIcons.clock,
            text: appointment.time,
            iconSize: 12,
            gap: 6,
            style: detailStyle,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: confirmed ? AppColors.primary15 : AppColors.white5,
                  border: Border.all(
                    color: confirmed ? AppColors.primary30 : AppColors.white10,
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: AppText.body(
                    12,
                    color: confirmed ? AppColors.primary : AppColors.gray88,
                    weight: FontWeight.w700,
                    letterSpacing: 0.72,
                  ),
                ),
              ),
              if (cancel != null)
                DangerButton(
                  label: 'CANCELAR',
                  icon: LucideIcons.x,
                  onPressed: cancel,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  fontSize: 12,
                  iconSize: 14,
                  letterSpacing: 0.72,
                  gap: 6,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
