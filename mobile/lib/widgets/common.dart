import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../theme.dart';
import '../utils/dates.dart';

/// Substitui o `motion.div` do framer-motion: aparece com fade e um
/// deslocamento inicial (x/y), com atraso opcional.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.offset = const Offset(0, 20),
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final Offset offset;
  final Duration delay;
  final Duration duration;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progress,
      child: widget.child,
      builder: (context, child) {
        final t = _progress.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: widget.offset * (1 - t),
            child: child,
          ),
        );
      },
    );
  }
}

/// Título grande em Bebas Neue com a linha dourada embaixo
/// (booking-main-title, admin-main-title, perfil-title...).
class PageTitle extends StatelessWidget {
  const PageTitle(
    this.text, {
    super.key,
    required this.size,
    this.lineWidth = 128,
    this.lineHeight = 4,
    this.gap = 8,
    this.letterSpacing,
  });

  final String text;
  final double size;
  final double lineWidth;
  final double lineHeight;
  final double gap;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: AppText.display(
            size,
            letterSpacing: letterSpacing ?? size * 0.05,
            height: 1,
          ),
        ),
        SizedBox(height: gap),
        Container(width: lineWidth, height: lineHeight, color: AppColors.primary),
      ],
    );
  }
}

/// Card padrão das telas internas: fundo #161616 e borda dourada 20%.
class PanelCard extends StatelessWidget {
  const PanelCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.borderColor = AppColors.primary20,
    this.color = AppColors.card,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color borderColor;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }
}

/// Caixa de mensagem de erro/sucesso (login-error, perfil-error...).
class MessageBox extends StatelessWidget {
  const MessageBox.error(this.text, {super.key, this.centered = true})
      : isError = true;

  const MessageBox.success(this.text, {super.key, this.centered = false})
      : isError = false;

  final String text;
  final bool isError;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: isError ? AppColors.danger15 : AppColors.primary15,
        border: Border.all(
          color: isError ? AppColors.danger40 : AppColors.primary40,
        ),
      ),
      child: Text(
        text,
        textAlign: centered ? TextAlign.center : TextAlign.start,
        style: AppText.body(
          14,
          color: isError ? AppColors.danger : AppColors.primary,
        ),
      ),
    );
  }
}

/// Botão quadrado genérico. Troca o fundo ao pressionar, como o :hover do site.
class BoxButton extends StatelessWidget {
  const BoxButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.background = Colors.transparent,
    this.pressedBackground,
    this.foreground,
    this.pressedForeground,
    this.borderColor,
    this.padding = EdgeInsets.zero,
    this.height,
    this.width,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color background;
  final Color? pressedBackground;
  final Color? foreground;
  final Color? pressedForeground;
  final Color? borderColor;
  final EdgeInsetsGeometry padding;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final border = borderColor;
    Widget button = TextButton(
      onPressed: onPressed,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.pressed)
              ? (pressedBackground ?? background)
              : background,
        ),
        foregroundColor: foreground == null
            ? null
            : WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.pressed)
                    ? (pressedForeground ?? foreground)
                    : foreground,
              ),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        shape: const WidgetStatePropertyAll(RoundedRectangleBorder()),
        side: border == null
            ? null
            : WidgetStatePropertyAll(BorderSide(color: border)),
        padding: WidgetStatePropertyAll(padding),
        minimumSize: const WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        splashFactory: NoSplash.splashFactory,
      ),
      child: child,
    );
    if (height != null || width != null) {
      button = SizedBox(height: height, width: width, child: button);
    }
    return button;
  }
}

/// Botão dourado cheio (hero-button, login-btn, booking-confirm-btn...).
class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.textStyle,
    this.icon,
    this.iconSize = 18,
    this.height = 58,
    this.expand = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.foreground = AppColors.page,
  });

  final String label;
  final VoidCallback? onPressed;
  final TextStyle textStyle;
  final IconData? icon;
  final double iconSize;
  final double height;
  final bool expand;
  final EdgeInsetsGeometry padding;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return BoxButton(
      onPressed: onPressed,
      background: AppColors.primary,
      pressedBackground: AppColors.accent,
      padding: padding,
      height: height,
      width: expand ? double.infinity : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: iconSize, color: foreground),
            const SizedBox(width: 8),
          ],
          Flexible(
            // Mantém o texto em uma linha; só reduz se não couber na tela.
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: textStyle.copyWith(color: foreground),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botão vermelho (perfil-logout-btn, perfil-cancel-btn).
class DangerButton extends StatelessWidget {
  const DangerButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    this.fontSize = 14,
    this.iconSize = 16,
    this.letterSpacing = 1.1,
    this.gap = 8,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final double iconSize;
  final double letterSpacing;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return BoxButton(
      onPressed: onPressed,
      background: AppColors.danger10,
      pressedBackground: AppColors.danger20,
      borderColor: AppColors.danger40,
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: iconSize, color: AppColors.danger),
          SizedBox(width: gap),
          Text(
            label,
            style: AppText.body(
              fontSize,
              color: AppColors.danger,
              weight: FontWeight.w700,
              letterSpacing: letterSpacing,
            ),
          ),
        ],
      ),
    );
  }
}

/// Link "VOLTAR" com seta (login-back, perfil-back).
class BackLink extends StatelessWidget {
  const BackLink({super.key, required this.onPressed, this.useBodyFont = false});

  final VoidCallback onPressed;

  /// O perfil usa Rajdhani. O login usa a fonte padrão do botão.
  final bool useBodyFont;

  @override
  Widget build(BuildContext context) {
    final style = useBodyFont
        ? AppText.body(13, letterSpacing: 1)
        : AppText.system(13, letterSpacing: 1);
    return BoxButton(
      onPressed: onPressed,
      foreground: AppColors.gray77,
      pressedForeground: AppColors.primary,
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(LucideIcons.arrowLeft, size: 15),
          const SizedBox(width: 8),
          Text('VOLTAR', style: style),
        ],
      ),
    );
  }
}

/// Rótulo acima dos campos.
class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key, this.style});

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: style ??
            AppText.body(
              14,
              color: AppColors.gray7a,
              weight: FontWeight.w500,
              letterSpacing: 0.56,
            ),
      ),
    );
  }
}

/// Campo de texto quadrado com ícone à esquerda e botão opcional à direita,
/// no mesmo formato dos inputs do site.
class BoxInput extends StatelessWidget {
  const BoxInput({
    super.key,
    this.controller,
    this.hint,
    this.icon,
    this.iconSize = 18,
    this.iconColor = AppColors.gray77,
    this.iconLeft = 16,
    this.paddingLeft = 16,
    this.paddingRight = 16,
    this.height = 52,
    this.fillColor = AppColors.input,
    this.borderColor = AppColors.primary20,
    this.focusColor = AppColors.primary,
    required this.textStyle,
    required this.hintStyle,
    this.obscureText = false,
    this.readOnly = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.validator,
    this.suffix,
  });

  final TextEditingController? controller;
  final String? hint;
  final IconData? icon;
  final double iconSize;
  final Color iconColor;
  final double iconLeft;

  /// Espaço até o texto. Com ícone, é o padding-left do CSS (ex.: 48px).
  final double paddingLeft;
  final double paddingRight;
  final double height;
  final Color fillColor;
  final Color borderColor;
  final Color focusColor;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final bool obscureText;
  final bool readOnly;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;

  /// Widget à direita (ex.: botão de mostrar senha). Ocupa [paddingRight].
  final Widget? suffix;

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: color),
      );

  @override
  Widget build(BuildContext context) {
    final fontSize = textStyle.fontSize ?? 15;
    final style = textStyle.copyWith(height: 1.2);
    final vertical = ((height - fontSize * 1.2) / 2).clamp(4.0, 40.0);

    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      onChanged: onChanged,
      validator: validator,
      style: style,
      cursorColor: AppColors.primary,
      textAlignVertical: TextAlignVertical.center,
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: fillColor,
        hintText: hint,
        hintStyle: hintStyle.copyWith(height: 1.2),
        contentPadding: EdgeInsets.fromLTRB(
          icon == null ? paddingLeft : 0,
          vertical,
          suffix == null ? paddingRight : 0,
          vertical,
        ),
        prefixIcon: icon == null
            ? null
            : SizedBox(
                width: paddingLeft,
                child: Padding(
                  padding: EdgeInsets.only(left: iconLeft),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(icon, size: iconSize, color: iconColor),
                  ),
                ),
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix == null
            ? null
            : SizedBox(width: paddingRight, child: suffix),
        suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        enabledBorder: _border(borderColor),
        border: _border(borderColor),
        focusedBorder: _border(readOnly ? borderColor : focusColor),
        errorBorder: _border(AppColors.danger40),
        focusedErrorBorder: _border(AppColors.danger),
        errorStyle: AppText.body(13, color: AppColors.danger),
        errorMaxLines: 2,
      ),
    );
  }
}

/// Botão de olho para mostrar/ocultar senha (input-eye, perfil-eye).
class EyeToggle extends StatelessWidget {
  const EyeToggle({
    super.key,
    required this.visible,
    required this.onToggle,
    this.size = 16,
    this.color = AppColors.gray6f,
    this.right = 14,
  });

  final bool visible;
  final VoidCallback onToggle;
  final double size;
  final Color color;
  final double right;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onToggle,
      child: Padding(
        padding: EdgeInsets.only(right: right),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(
            visible ? LucideIcons.eyeOff : LucideIcons.eye,
            size: size,
            color: color,
          ),
        ),
      ),
    );
  }
}

/// Campo de data (input type="date"). Guarda o valor como AAAA-MM-DD
/// e mostra no formato dd/mm/aaaa.
class DateBoxField extends StatelessWidget {
  const DateBoxField({
    super.key,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.height = 52,
    this.fontSize = 16,
    this.clearable = false,
  });

  /// Data AAAA-MM-DD ou texto vazio.
  final String value;
  final ValueChanged<String> onChanged;

  /// Equivalente ao atributo `min` do input.
  final DateTime? firstDate;
  final double height;
  final double fontSize;
  final bool clearable;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final first = firstDate ?? DateTime(2000);
    final last = DateTime(today.year + 5, 12, 31);
    var initial = parseIsoDate(value) ?? today;
    if (initial.isBefore(first)) initial = first;
    if (initial.isAfter(last)) initial = last;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) onChanged(isoDate(picked));
  }

  @override
  Widget build(BuildContext context) {
    final empty = value.isEmpty;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _pick(context),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.input,
          border: Border.all(color: AppColors.primary20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                empty ? 'dd/mm/aaaa' : formatDateBr(value),
                style: AppText.body(
                  fontSize,
                  color: empty ? AppColors.gray6f : AppColors.text,
                ),
              ),
            ),
            if (clearable && !empty)
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(''),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Icon(LucideIcons.x, size: 16, color: AppColors.gray6f),
                ),
              ),
            const Icon(LucideIcons.calendar, size: 18, color: AppColors.gray9c),
          ],
        ),
      ),
    );
  }
}

/// Select estilizado (admin-select).
class SelectBox<T> extends StatelessWidget {
  const SelectBox({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.height = 48,
  });

  final T value;
  final List<(T, String)> items;
  final ValueChanged<T> onChanged;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.input,
        border: Border.all(color: AppColors.primary20),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          dropdownColor: AppColors.input,
          borderRadius: BorderRadius.zero,
          iconEnabledColor: AppColors.gray9c,
          icon: const Icon(LucideIcons.chevronDown, size: 18),
          style: AppText.body(15, color: AppColors.text),
          items: [
            for (final (itemValue, label) in items)
              DropdownMenuItem<T>(value: itemValue, child: Text(label)),
          ],
          onChanged: (selected) {
            if (selected != null) onChanged(selected);
          },
        ),
      ),
    );
  }
}

/// Ícone + texto em linha (appointment-detail-row, admin-cell-icon-row...).
class IconText extends StatelessWidget {
  const IconText({
    super.key,
    required this.icon,
    required this.text,
    required this.style,
    this.iconSize = 14,
    this.iconColor,
    this.gap = 8,
  });

  final IconData icon;
  final String text;
  final TextStyle style;
  final double iconSize;
  final Color? iconColor;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: iconColor ?? style.color),
        SizedBox(width: gap),
        Flexible(child: Text(text, style: style)),
      ],
    );
  }
}
