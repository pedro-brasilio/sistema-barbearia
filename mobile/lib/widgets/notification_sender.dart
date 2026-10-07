import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../api.dart';
import '../theme.dart';
import 'common.dart';

/// Mesmos filtros do Notificacaocontrolador da API.
const _publicos = [
  ('todos', 'Todos os clientes'),
  ('sem_agendamento', 'Sem horário agendado'),
  ('com_agendamento', 'Com horário agendado'),
  ('nunca_agendou', 'Nunca agendaram'),
  ('sumidos', 'Sumidos (último horário há mais de 30 dias)'),
];

/// Quanto o Android mostra na notificação (a API confere os mesmos limites).
const _maxTitulo = 65;
const _maxMensagem = 240;

/// Versão mobile do components/NotificationSender.tsx: aba NOTIFICAÇÕES
/// do painel do administrador. A API escolhe os clientes e o n8n envia.
/// A API só aceita o administrador (pelo token do login).
class NotificationSender extends StatefulWidget {
  const NotificationSender({super.key});

  @override
  State<NotificationSender> createState() => _NotificationSenderState();
}

class _NotificationSenderState extends State<NotificationSender> {
  final _titulo = TextEditingController();
  final _mensagem = TextEditingController();
  String _filtro = 'todos';

  /// Quantos clientes recebem; null enquanto conta ou se der erro.
  int? _publico;
  bool _erroContagem = false;
  int _contagemAtual = 0;

  bool _enviando = false;
  ({bool ok, String texto})? _resultado;

  @override
  void initState() {
    super.initState();
    // O botão só habilita com título e mensagem preenchidos.
    _titulo.addListener(_atualizar);
    _mensagem.addListener(_atualizar);
    _contar();
  }

  @override
  void dispose() {
    _titulo.dispose();
    _mensagem.dispose();
    super.dispose();
  }

  void _atualizar() => setState(() {});

  Future<void> _contar() async {
    final pedido =
        ++_contagemAtual; // descarta a resposta se o filtro mudou de novo
    setState(() {
      _publico = null;
      _erroContagem = false;
    });
    try {
      final dados = await Api.contarPublicoNotificacao(_filtro);
      if (!mounted || pedido != _contagemAtual) return;
      setState(() => _publico = (dados['total'] as num).toInt());
    } on ApiException {
      if (!mounted || pedido != _contagemAtual) return;
      setState(() => _erroContagem = true);
    }
  }

  Future<bool> _confirmar() {
    final quem =
        _publico != null ? '$_publico cliente(s)' : 'os clientes do filtro';
    return confirmar(
      context,
      titulo: 'ENVIAR NOTIFICAÇÃO?',
      texto: '"${_titulo.text.trim()}" vai para $quem.',
      acao: 'ENVIAR',
    );
  }

  Future<void> _enviar() async {
    if (!await _confirmar() || !mounted) return;

    setState(() {
      _enviando = true;
      _resultado = null;
    });
    try {
      final r = await Api.enviarNotificacao(
        titulo: _titulo.text,
        mensagem: _mensagem.text,
        filtro: _filtro,
      );
      final total = (r['total'] as num).toInt();
      final enviados = (r['enviados'] as num).toInt();
      final falhas = (r['falhas'] as num).toInt();
      if (!mounted) return;
      setState(() {
        if (total == 0) {
          _resultado = (
            ok: false,
            texto: 'Nenhum cliente com o app se encaixa nesse filtro. '
                'Nada foi enviado.',
          );
        } else if (falhas == 0) {
          _resultado = (
            ok: true,
            texto: 'Notificação enviada para $enviados celular(es).',
          );
          _titulo.clear();
          _mensagem.clear();
        } else {
          _resultado = (
            ok: enviados > 0,
            texto: 'Enviada para $enviados de $total celular(es). '
                'Falhou em $falhas: ${r['erro'] ?? ''}',
          );
        }
      });
    } on ApiException catch (err) {
      if (mounted) setState(() => _resultado = (ok: false, texto: err.message));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppText.body(
      13,
      color: AppColors.gray7a,
      weight: FontWeight.w600,
      letterSpacing: 1.04,
    );
    final inputStyle = AppText.body(15, color: AppColors.text);
    final hintStyle = AppText.body(15, color: AppColors.gray6f);

    final publico = _publico;
    final semPublico = publico == 0 || _erroContagem;
    final textoPublico = _erroContagem
        ? 'Não foi possível contar os clientes.'
        : publico == null
            ? 'Contando clientes...'
            : publico == 0
                ? 'Nenhum cliente com o app nesse filtro.'
                : '$publico cliente(s) com o app vão receber.';

    final podeEnviar = !_enviando &&
        publico != 0 &&
        _titulo.text.trim().isNotEmpty &&
        _mensagem.text.trim().isNotEmpty;

    return PanelCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(LucideIcons.bell, size: 18, color: AppColors.primary),
              const SizedBox(width: 10),
              Text(
                'ENVIAR NOTIFICAÇÃO',
                style: AppText.body(
                  20,
                  color: AppColors.text,
                  weight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              style: AppText.body(15, color: AppColors.gray7a),
              children: [
                const TextSpan(
                  text: 'Avisos e promoções chegam no celular de quem usa o '
                      'app. Escreva ',
                ),
                TextSpan(
                  text: '{nome}',
                  style: AppText.body(
                    15,
                    color: AppColors.primary,
                    weight: FontWeight.w600,
                  ),
                ),
                const TextSpan(
                  text: ' para colocar o primeiro nome do cliente.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FieldLabel('TÍTULO', style: labelStyle),
          BoxInput(
            controller: _titulo,
            hint: 'Promoção de outubro',
            height: 48,
            maxLength: _maxTitulo,
            textStyle: inputStyle,
            hintStyle: hintStyle,
          ),
          const SizedBox(height: 8),
          FieldLabel('MENSAGEM', style: labelStyle),
          BoxInput(
            controller: _mensagem,
            hint: 'Olá {nome}! Corte + barba com 20% de desconto até sexta.',
            minLines: 4,
            maxLines: 6,
            maxLength: _maxMensagem,
            keyboardType: TextInputType.multiline,
            textStyle: inputStyle,
            hintStyle: hintStyle,
          ),
          const SizedBox(height: 8),
          FieldLabel('ENVIAR PARA', style: labelStyle),
          SelectBox<String>(
            value: _filtro,
            items: _publicos,
            onChanged: (value) {
              setState(() => _filtro = value);
              _contar();
            },
          ),
          const SizedBox(height: 16),
          IconText(
            icon: LucideIcons.users,
            text: textoPublico,
            iconColor: semPublico ? AppColors.gray7a : AppColors.primary,
            style: AppText.body(
              15,
              color: semPublico ? AppColors.gray7a : AppColors.primary,
              weight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Opacity(
            opacity: podeEnviar ? 1 : 0.4,
            child: GoldButton(
              label: _enviando ? 'ENVIANDO...' : 'ENVIAR NOTIFICAÇÃO',
              icon: LucideIcons.send,
              height: 52,
              textStyle: AppText.body(
                16,
                weight: FontWeight.w700,
                letterSpacing: 1.9,
              ),
              onPressed: podeEnviar ? _enviar : null,
            ),
          ),
          if (_resultado case final resultado?) ...[
            const SizedBox(height: 16),
            resultado.ok
                ? MessageBox.success(resultado.texto)
                : MessageBox.error(resultado.texto, centered: false),
          ],
        ],
      ),
    );
  }
}
