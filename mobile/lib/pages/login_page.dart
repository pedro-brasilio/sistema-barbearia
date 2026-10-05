import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../api.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Versão mobile do pages/Login.tsx.
/// No site, abaixo de 1200px o painel "BEM VINDO" some e fica só o card.
class LoginPage extends StatefulWidget {
  const LoginPage({
    super.key,
    required this.onNavigateBack,
    required this.onLoginSuccess,
  });

  final VoidCallback onNavigateBack;
  final ValueChanged<AppUser> onLoginSuccess;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true;
  bool _loading = false;
  String _erro = '';
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _name = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  // Validações que o navegador faz sozinho (required e type="email").
  String? _required(String? value) =>
      (value == null || value.isEmpty) ? 'Preencha este campo.' : null;

  String? _emailValidator(String? value) {
    final required = _required(value);
    if (required != null) return required;
    final email = value!.trim();
    final at = email.indexOf('@');
    if (at <= 0 || at == email.length - 1) {
      return 'Insira um endereço de e-mail válido.';
    }
    return null;
  }

  dynamic _pick(dynamic data, List<String> keys) {
    if (data is! Map) return null;
    for (final key in keys) {
      final value = data[key];
      if (value != null) return value;
    }
    return null;
  }

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _erro = '');

    if (!_isLoginMode && _password.text != _confirmPassword.text) {
      setState(() => _erro = 'As senhas não coincidem.');
      return;
    }

    setState(() => _loading = true);

    try {
      if (_isLoginMode) {
        final user = await Api.loginCliente(
          email: _email.text,
          senha: _password.text,
        );

        widget.onLoginSuccess(AppUser(
          id: _asInt(_pick(user, ['id', 'Id'])),
          name: (_pick(user, ['Nome', 'nome']) ?? _email.text.split('@').first)
              .toString(),
          email: (_pick(user, ['Email', 'email']) ?? _email.text).toString(),
          telefone: (_pick(user, ['Telefone', 'telefone']) ?? '').toString(),
          isAdmin: _pick(user, ['IsAdmin', 'isAdmin']) == true,
        ));
      } else {
        final user = await Api.cadastrarCliente(
          nome: _name.text,
          telefone: _phone.text,
          email: _email.text,
          senha: _password.text,
        );

        widget.onLoginSuccess(AppUser(
          id: _asInt(_pick(user, ['id', 'Id'])),
          name: (_pick(user, ['Nome', 'nome']) ?? _name.text).toString(),
          email: (_pick(user, ['Email', 'email']) ?? _email.text).toString(),
          telefone:
              (_pick(user, ['Telefone', 'telefone']) ?? _phone.text).toString(),
          isAdmin: _pick(user, ['IsAdmin', 'isAdmin']) == true,
        ));
      }
    } catch (err) {
      final message = err is ApiException ? err.message : err.toString();
      if (mounted) {
        setState(() => _erro =
            message.isNotEmpty ? message : 'Algo deu errado. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _erro = '';
      _showPassword = false;
      _showConfirmPassword = false;
      // Nova chave limpa as mensagens de validação sem apagar o que foi digitado.
      _formKey = GlobalKey<FormState>();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: FadeSlideIn(
        offset: const Offset(40, 0),
        delay: const Duration(milliseconds: 150),
        duration: const Duration(milliseconds: 700),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: BoxDecoration(
            color: AppColors.loginCard,
            border: Border.all(color: AppColors.loginBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: BackLink(onPressed: widget.onNavigateBack),
              ),
              const SizedBox(height: 24),
              // login-header
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _isLoginMode ? 'LOGIN' : 'CADASTRO',
                    style: AppText.display(64, letterSpacing: 3, height: 1),
                  ),
                  const SizedBox(height: 10),
                  Container(width: 78, height: 4, color: AppColors.primary),
                ],
              ),
              const SizedBox(height: 35),
              if (_erro.isNotEmpty) ...[
                MessageBox.error(_erro),
                const SizedBox(height: 8),
              ],
              Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!_isLoginMode)
                        _LoginField(
                          label: 'NOME COMPLETO',
                          child: _input(
                            controller: _name,
                            hint: 'Seu nome',
                            icon: LucideIcons.user,
                            validator: _required,
                            autofillHints: const [AutofillHints.name],
                          ),
                        ),
                      _LoginField(
                        label: 'E-MAIL',
                        child: _input(
                          controller: _email,
                          hint: 'seu@email.com',
                          icon: LucideIcons.mail,
                          keyboardType: TextInputType.emailAddress,
                          validator: _emailValidator,
                          autofillHints: const [AutofillHints.email],
                        ),
                      ),
                      if (!_isLoginMode)
                        _LoginField(
                          label: 'TELEFONE',
                          child: _input(
                            controller: _phone,
                            hint: '(11) 99999-9999',
                            icon: LucideIcons.phone,
                            keyboardType: TextInputType.phone,
                            validator: _required,
                            autofillHints: const [AutofillHints.telephoneNumber],
                          ),
                        ),
                      _LoginField(
                        label: 'SENHA',
                        child: _input(
                          controller: _password,
                          hint: '••••••••',
                          icon: LucideIcons.lock,
                          obscure: !_showPassword,
                          validator: _required,
                          autofillHints: const [AutofillHints.password],
                          suffix: EyeToggle(
                            visible: _showPassword,
                            onToggle: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                      ),
                      if (!_isLoginMode)
                        _LoginField(
                          label: 'CONFIRMAR SENHA',
                          child: _input(
                            controller: _confirmPassword,
                            hint: '••••••••',
                            icon: LucideIcons.lock,
                            obscure: !_showConfirmPassword,
                            validator: _required,
                            suffix: EyeToggle(
                              visible: _showConfirmPassword,
                              onToggle: () => setState(() =>
                                  _showConfirmPassword = !_showConfirmPassword),
                            ),
                          ),
                        ),
                      if (_isLoginMode)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Text(
                            'Esqueceu a senha?',
                            textAlign: TextAlign.right,
                            style: AppText.body(12, color: AppColors.gray77),
                          ),
                        ),
                      GoldButton(
                        label: _loading
                            ? 'AGUARDE...'
                            : _isLoginMode
                                ? 'ENTRAR'
                                : 'CRIAR CONTA',
                        onPressed: _loading ? null : _handleSubmit,
                        foreground: AppColors.black,
                        textStyle: AppText.system(
                          14,
                          weight: FontWeight.w800,
                          letterSpacing: 4,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(height: 1, color: AppColors.loginBorder),
                      const SizedBox(height: 30),
                      // login-toggle
                      Text(
                        _isLoginMode
                            ? 'Não tem uma conta ainda?'
                            : 'Já tem uma conta?',
                        textAlign: TextAlign.center,
                        style: AppText.body(15, color: AppColors.gray77),
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: BoxButton(
                          onPressed: _toggleMode,
                          borderColor: AppColors.primary,
                          pressedBackground: AppColors.primary8,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 12,
                          ),
                          child: Text(
                            _isLoginMode ? 'CLIQUE AQUI' : 'FAZER LOGIN',
                            style: AppText.system(
                              13,
                              color: AppColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required FormFieldValidator<String> validator,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    Iterable<String>? autofillHints,
  }) {
    return BoxInput(
      controller: controller,
      hint: hint,
      icon: icon,
      iconSize: 18,
      iconColor: AppColors.gray77,
      iconLeft: 16,
      paddingLeft: 48,
      paddingRight: 48,
      height: 56,
      fillColor: AppColors.loginInput,
      borderColor: AppColors.loginBorder,
      textStyle: AppText.system(15, color: AppColors.white),
      hintStyle: AppText.system(15, color: AppColors.gray66),
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      autofillHints: autofillHints,
      suffix: suffix,
    );
  }
}

/// input-group: rótulo + campo, com 22px de espaço embaixo.
class _LoginField extends StatelessWidget {
  const _LoginField({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FieldLabel(
            label,
            style: AppText.body(12, color: AppColors.gray77, letterSpacing: 1),
          ),
          child,
        ],
      ),
    );
  }
}
