import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models.dart';
import '../theme.dart';

/// Telas do app. Mesmos valores do estado `view` do App.tsx.
enum AppView { home, login, booking, admin, perfil }

/// Fundo do header: rgba(9,9,11,.8) + gradiente dourado sutil + blur.
class _HeaderBackground extends StatelessWidget {
  const _HeaderBackground({required this.child, required this.border});

  final Widget child;
  final Border border;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          decoration: BoxDecoration(color: AppColors.headerBg, border: border),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary5,
                  Colors.transparent,
                  AppColors.accent5,
                ],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Cabeçalho com o logo "BARBERSHOP / ESTILO & TRADIÇÃO" (Header.tsx).
class AppHeader extends StatelessWidget {
  const AppHeader({super.key, required this.onLogoTap});

  final VoidCallback onLogoTap;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    return _HeaderBackground(
      border: const Border(bottom: BorderSide(color: AppColors.headerBorder)),
      child: Padding(
        padding: EdgeInsets.only(top: topInset),
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onLogoTap,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _LogoIcon(),
                    const SizedBox(width: 16),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: _logoText(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logoText() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BARBERSHOP',
          style: AppText.display(34, letterSpacing: 3, height: 1),
        ),
        const SizedBox(height: 2),
        Text(
          'ESTILO & TRADIÇÃO',
          style: AppText.body(11, color: AppColors.gray9c, letterSpacing: 4),
        ),
      ],
    );
  }
}

/// Tesoura com o brilho dourado desfocado atrás (logo-icon-wrapper::before).
class _LogoIcon extends StatelessWidget {
  const _LogoIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -9,
            top: -9,
            width: 56,
            height: 56,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.primary45,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const Icon(LucideIcons.scissors, size: 28, color: AppColors.primary),
        ],
      ),
    );
  }
}

/// Menu de navegação. No site fica no topo (nav-btn); no celular vai para a
/// parte de baixo da tela, com os mesmos itens, cores e estado ativo.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentView,
    required this.user,
    required this.onNavigate,
  });

  final AppView currentView;
  final AppUser? user;
  final ValueChanged<AppView> onNavigate;

  @override
  Widget build(BuildContext context) {
    final currentUser = user;
    // LOGIN vira o primeiro nome do usuário após o login.
    final loginLabel = currentUser == null
        ? 'LOGIN'
        : currentUser.name.trim().split(' ').first.toUpperCase();

    return _HeaderBackground(
      border: const Border(top: BorderSide(color: AppColors.headerBorder)),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _NavButton(
                label: 'INÍCIO',
                icon: LucideIcons.house,
                active: currentView == AppView.home,
                onTap: () => onNavigate(AppView.home),
              ),
              _NavButton(
                label: 'AGENDAR',
                icon: LucideIcons.calendar,
                active: currentView == AppView.booking,
                onTap: () => onNavigate(AppView.booking),
              ),
              _NavButton(
                label: loginLabel,
                icon: LucideIcons.user,
                active: currentView == AppView.login ||
                    currentView == AppView.perfil,
                onTap: () => onNavigate(AppView.login),
              ),
              // ADMIN só aparece se for admin.
              if (currentUser?.isAdmin ?? false)
                _NavButton(
                  label: 'ADMIN',
                  icon: LucideIcons.layoutGrid,
                  active: currentView == AppView.admin,
                  onTap: () => onNavigate(AppView.admin),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.gray9c;
    return Expanded(
      child: Material(
        color: active ? AppColors.primary10 : Colors.transparent,
        child: InkWell(
          onTap: onTap,
          highlightColor: const Color(0xFF18181B),
          splashColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: active ? AppColors.primary : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.body(
                    14,
                    color: color,
                    weight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
