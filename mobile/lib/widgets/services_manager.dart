import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../api.dart';
import '../models.dart';
import '../theme.dart';
import 'common.dart';

/// Versão mobile do components/ServicesManager.tsx: aba SERVIÇOS do painel.
/// Cadastra, altera e remove os serviços no banco; o início e o agendamento
/// (site e app) leem a mesma lista. A API só aceita o administrador
/// (pelo token do login).
class ServicesManager extends StatefulWidget {
  const ServicesManager({
    super.key,
    required this.servicos,
    required this.onAlterado,
  });

  /// Serviços do banco; null enquanto carrega.
  final List<Servico>? servicos;

  /// Recarrega a lista do banco.
  final Future<void> Function() onAlterado;

  @override
  State<ServicesManager> createState() => _ServicesManagerState();
}

class _ServicesManagerState extends State<ServicesManager> {
  final _formKey = GlobalKey();
  final _nome = TextEditingController();
  final _preco = TextEditingController();
  final _duracao = TextEditingController(text: '30');

  Servico? _editando;
  bool _salvando = false;
  ({bool ok, String texto})? _mensagem;

  @override
  void dispose() {
    _nome.dispose();
    _preco.dispose();
    _duracao.dispose();
    super.dispose();
  }

  void _limparFormulario() {
    _editando = null;
    _nome.clear();
    _preco.clear();
    _duracao.text = '30';
  }

  void _editar(Servico servico) {
    setState(() {
      _editando = servico;
      _nome.text = servico.nome;
      _preco.text = formatPreco(servico.preco).replaceFirst(r'R$ ', '');
      _duracao.text = '${servico.duracaoMinutos}';
      _mensagem = null;
    });
    // O formulário fica acima da lista.
    final formulario = _formKey.currentContext;
    if (formulario != null) {
      Scrollable.ensureVisible(
        formulario,
        duration: const Duration(milliseconds: 300),
      );
    }
  }

  Future<void> _salvar() async {
    final nome = _nome.text.trim();
    final preco = double.tryParse(_preco.text.trim().replaceAll(',', '.'));
    final duracao = int.tryParse(_duracao.text.trim());
    if (nome.isEmpty || preco == null || duracao == null) {
      setState(() => _mensagem = (
            ok: false,
            texto: 'Preencha o nome, o preço e a duração.',
          ));
      return;
    }

    final editando = _editando;
    setState(() {
      _salvando = true;
      _mensagem = null;
    });
    try {
      if (editando != null) {
        await Api.atualizarServico(
          id: editando.id,
          nome: nome,
          preco: preco,
          duracaoMinutos: duracao,
        );
      } else {
        await Api.criarServico(
          nome: nome,
          preco: preco,
          duracaoMinutos: duracao,
        );
      }
      if (!mounted) return;
      setState(() {
        _mensagem = (
          ok: true,
          texto: editando != null
              ? '"$nome" foi atualizado.'
              : '"$nome" foi adicionado.',
        );
        _limparFormulario();
      });
      await widget.onAlterado();
    } on ApiException catch (err) {
      if (mounted) setState(() => _mensagem = (ok: false, texto: err.message));
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _remover(Servico servico) async {
    final confirmado = await confirmar(
      context,
      titulo: 'REMOVER SERVIÇO?',
      texto: '"${servico.nome}" sai do site e do app. Os agendamentos já '
          'feitos continuam com esse nome.',
      acao: 'REMOVER',
    );
    if (!confirmado || !mounted) return;

    setState(() => _mensagem = null);
    try {
      await Api.removerServico(servico.id);
      if (!mounted) return;
      setState(() {
        if (_editando?.id == servico.id) _limparFormulario();
        _mensagem = (ok: true, texto: '"${servico.nome}" foi removido.');
      });
      await widget.onAlterado();
    } on ApiException catch (err) {
      if (mounted) setState(() => _mensagem = (ok: false, texto: err.message));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeSlideIn(
          delay: const Duration(milliseconds: 100),
          child: KeyedSubtree(key: _formKey, child: _buildFormulario()),
        ),
        const SizedBox(height: 24),
        FadeSlideIn(
          delay: const Duration(milliseconds: 200),
          child: _buildLista(),
        ),
      ],
    );
  }

  Widget _buildFormulario() {
    final labelStyle = AppText.body(
      13,
      color: AppColors.gray7a,
      weight: FontWeight.w600,
      letterSpacing: 1.04,
    );
    final inputStyle = AppText.body(15, color: AppColors.text);
    final hintStyle = AppText.body(15, color: AppColors.gray6f);
    final editando = _editando != null;

    return PanelCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Titulo(
            icon: editando ? LucideIcons.pencil : LucideIcons.plus,
            text: editando ? 'EDITAR SERVIÇO' : 'NOVO SERVIÇO',
          ),
          const SizedBox(height: 20),
          FieldLabel('NOME', style: labelStyle),
          BoxInput(
            controller: _nome,
            hint: 'Ex.: Pigmentação de barba',
            height: 48,
            maxLength: 40,
            textStyle: inputStyle,
            hintStyle: hintStyle,
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FieldLabel(r'PREÇO (R$)', style: labelStyle),
                    BoxInput(
                      controller: _preco,
                      hint: '45',
                      height: 48,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textStyle: inputStyle,
                      hintStyle: hintStyle,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    FieldLabel('DURAÇÃO (MIN)', style: labelStyle),
                    BoxInput(
                      controller: _duracao,
                      height: 48,
                      keyboardType: TextInputType.number,
                      textStyle: inputStyle,
                      hintStyle: hintStyle,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Opacity(
            opacity: _salvando ? 0.4 : 1,
            child: GoldButton(
              label: _salvando
                  ? 'SALVANDO...'
                  : editando
                      ? 'SALVAR ALTERAÇÕES'
                      : 'ADICIONAR SERVIÇO',
              icon: editando ? LucideIcons.save : LucideIcons.plus,
              height: 52,
              textStyle: AppText.body(
                16,
                weight: FontWeight.w700,
                letterSpacing: 1.9,
              ),
              onPressed: _salvando ? null : _salvar,
            ),
          ),
          if (editando) ...[
            const SizedBox(height: 12),
            BoxButton(
              onPressed: () => setState(() {
                _limparFormulario();
                _mensagem = null;
              }),
              height: 44,
              borderColor: AppColors.white12,
              child: IconText(
                icon: LucideIcons.x,
                text: 'CANCELAR EDIÇÃO',
                iconSize: 14,
                iconColor: AppColors.gray88,
                style: AppText.body(
                  14,
                  color: AppColors.gray88,
                  weight: FontWeight.w600,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ],
          if (_mensagem case final mensagem?) ...[
            const SizedBox(height: 16),
            mensagem.ok
                ? MessageBox.success(mensagem.texto)
                : MessageBox.error(mensagem.texto, centered: false),
          ],
        ],
      ),
    );
  }

  Widget _buildLista() {
    final servicos = widget.servicos;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.primary20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: _Titulo(
              icon: LucideIcons.scissors,
              text: 'SERVIÇOS OFERECIDOS',
            ),
          ),
          if (servicos == null || servicos.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                servicos == null
                    ? 'Carregando serviços...'
                    : 'Nenhum serviço cadastrado.',
                textAlign: TextAlign.center,
                style: AppText.body(15, color: AppColors.gray55),
              ),
            )
          else
            for (var i = 0; i < servicos.length; i++)
              _ServicoLinha(
                servico: servicos[i],
                editando: _editando?.id == servicos[i].id,
                showDivider: i < servicos.length - 1,
                onEditar: () => _editar(servicos[i]),
                onRemover: () => _remover(servicos[i]),
              ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.primary10)),
            ),
            child: Text(
              'As mudanças aparecem na hora no início e no agendamento, '
              'no site e no app.',
              textAlign: TextAlign.center,
              style: AppText.body(14, color: AppColors.gray55),
            ),
          ),
        ],
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppText.body(
            20,
            color: AppColors.text,
            weight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}

class _ServicoLinha extends StatelessWidget {
  const _ServicoLinha({
    required this.servico,
    required this.editando,
    required this.showDivider,
    required this.onEditar,
    required this.onRemover,
  });

  final Servico servico;

  /// Serviço aberto no formulário.
  final bool editando;
  final bool showDivider;
  final VoidCallback onEditar;
  final VoidCallback onRemover;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: editando ? AppColors.primary8 : null,
        border: Border(
          left: BorderSide(
            color: editando ? AppColors.primary : Colors.transparent,
            width: 3,
          ),
          bottom: showDivider
              ? const BorderSide(color: AppColors.white4)
              : BorderSide.none,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  servico.nome,
                  style: AppText.body(
                    17,
                    color: AppColors.text,
                    weight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      formatPreco(servico.preco),
                      style: AppText.display(22, letterSpacing: 0.9, height: 1),
                    ),
                    const SizedBox(width: 16),
                    IconText(
                      icon: LucideIcons.clock,
                      text: '${servico.duracaoMinutos} min',
                      iconSize: 14,
                      iconColor: AppColors.primary,
                      style: AppText.body(14, color: AppColors.gray9c),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _BotaoAcao(
            icon: LucideIcons.pencil,
            tooltip: 'Editar',
            background: AppColors.primary15,
            borderColor: AppColors.primary40,
            color: AppColors.primary,
            pressedBackground: AppColors.primary,
            pressedColor: AppColors.page,
            onPressed: onEditar,
          ),
          const SizedBox(width: 8),
          _BotaoAcao(
            icon: LucideIcons.trash2,
            tooltip: 'Remover',
            background: AppColors.white4,
            borderColor: AppColors.white12,
            color: AppColors.gray88,
            pressedBackground: AppColors.danger20,
            pressedColor: AppColors.danger,
            onPressed: onRemover,
          ),
        ],
      ),
    );
  }
}

class _BotaoAcao extends StatelessWidget {
  const _BotaoAcao({
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
