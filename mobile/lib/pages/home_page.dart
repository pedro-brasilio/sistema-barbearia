import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../models.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// Versão mobile do components/Home.tsx: hero, serviços e informações.
class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.servicos,
    required this.onNavigateToBooking,
  });

  /// Serviços do banco; null enquanto carrega.
  final List<Servico>? servicos;
  final VoidCallback onNavigateToBooking;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Hero(onNavigateToBooking: onNavigateToBooking),
          _ServicesSection(services: servicos),
          const _InfoSection(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// HERO
// ---------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({required this.onNavigateToBooking});

  final VoidCallback onNavigateToBooking;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final titleSize = (width * 0.2).clamp(56.0, 90.0);

    return FadeSlideIn(
      offset: Offset.zero,
      duration: const Duration(milliseconds: 800),
      child: ClipRect(
        child: Stack(
          children: [
            // hero-gradient
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.backgroundAlt,
                      AppColors.backgroundAlt,
                      AppColors.primary10,
                    ],
                  ),
                ),
              ),
            ),
            // hero-lines
            const Positioned.fill(
              child: CustomPaint(painter: _VerticalLinesPainter()),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 48, 24, 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FadeSlideIn(
                    offset: const Offset(-50, 0),
                    delay: const Duration(milliseconds: 200),
                    duration: const Duration(milliseconds: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary5,
                            border: Border.all(color: AppColors.primary30),
                          ),
                          child: Text(
                            'DESDE 1998',
                            style: AppText.body(
                              12,
                              color: AppColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // hero-title
                        Text.rich(
                          const TextSpan(
                            children: [
                              TextSpan(text: 'ESTILO\n'),
                              TextSpan(
                                text: 'ATEMPORAL',
                                style: TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                          style: AppText.display(
                            titleSize,
                            color: AppColors.white,
                            letterSpacing: 3,
                            height: 0.9,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // hero-text
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Text(
                            'Tradição e excelência em cada corte. Profissionais '
                            'experientes, ambiente acolhedor e o melhor '
                            'atendimento da cidade.',
                            style: AppText.body(
                              18,
                              color: AppColors.gray9c,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        // hero-button
                        GoldButton(
                          label: 'AGENDAR HORÁRIO',
                          onPressed: onNavigateToBooking,
                          expand: false,
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          foreground: AppColors.black,
                          textStyle: AppText.body(
                            14,
                            weight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                  const FadeSlideIn(
                    offset: Offset(50, 0),
                    delay: Duration(milliseconds: 400),
                    duration: Duration(milliseconds: 800),
                    child: _HeroVisual(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Listras verticais finas do fundo do hero
/// (repeating-linear-gradient 90deg, 2px transparente / 2px dourado 3%).
class _VerticalLinesPainter extends CustomPainter {
  const _VerticalLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = AppColors.primary3;
    for (double x = 2; x < size.width; x += 4) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 2, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _VerticalLinesPainter oldDelegate) => false;
}

/// Quadrado dourado girado 3° com o card escuro e a tesoura (hero-visual).
class _HeroVisual extends StatelessWidget {
  const _HeroVisual();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 280,
      width: double.infinity,
      child: Stack(
        children: [
          Positioned.fill(
            child: Transform.rotate(
              angle: 3 * math.pi / 180,
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary20, AppColors.accent20],
                  ),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.heroVisualCard,
                  border: Border.all(color: AppColors.primary30, width: 2),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  LucideIcons.scissors,
                  size: 120,
                  color: AppColors.primary40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SERVIÇOS
// ---------------------------------------------------------------------------

class _ServicesSection extends StatelessWidget {
  const _ServicesSection({required this.services});

  final List<Servico>? services;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white2,
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FadeSlideIn(
            offset: const Offset(0, 30),
            duration: const Duration(milliseconds: 600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SERVIÇOS',
                  style: AppText.display(52, letterSpacing: 3, height: 1),
                ),
                const SizedBox(height: 4),
                Container(width: 130, height: 3, color: AppColors.primary),
              ],
            ),
          ),
          const SizedBox(height: 32),
          if (services case final lista? when lista.isNotEmpty)
            for (var i = 0; i < lista.length; i++) ...[
              if (i > 0) const SizedBox(height: 20),
              FadeSlideIn(
                offset: const Offset(0, 30),
                delay: Duration(milliseconds: 100 * i),
                child: _ServiceCard(service: lista[i]),
              ),
            ]
          else
            Text(
              services == null
                  ? 'Carregando serviços...'
                  : 'Nenhum serviço disponível no momento.',
              style: AppText.body(16, color: AppColors.gray9c),
            ),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.service});

  final Servico service;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.serviceCard,
        border: Border.all(color: AppColors.border222),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            // service-corner: quadrado dourado 140px deslocado 75% para fora.
            Positioned(
              top: -105,
              right: -105,
              child: Container(
                width: 140,
                height: 140,
                color: AppColors.primary5,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 40, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.nome,
                    style: AppText.body(
                      20,
                      color: AppColors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      runSpacing: 8,
                      children: [
                        Text(
                          formatPreco(service.preco),
                          style:
                              AppText.display(32, letterSpacing: 2, height: 1),
                        ),
                        IconText(
                          icon: LucideIcons.clock,
                          text: '${service.duracaoMinutos} min',
                          iconSize: 14,
                          gap: 4,
                          style: AppText.body(14, color: AppColors.gray9c),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// INFORMAÇÕES
// ---------------------------------------------------------------------------

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  static const _items = [
    (
      icon: LucideIcons.star,
      title: 'Excelência',
      text: 'Mais de 25 anos de tradição e qualidade',
    ),
    (
      icon: LucideIcons.clock,
      title: 'Horários Flexíveis',
      text: 'Seg-Sex: 9h-20h | Sáb: 9h-18h',
    ),
    (
      icon: LucideIcons.mapPin,
      title: 'Localização',
      text: 'Av. Principal, 1234 - Centro',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 64, 24, 64),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < _items.length; i++) ...[
            if (i > 0) const SizedBox(height: 20),
            FadeSlideIn(
              offset: const Offset(0, 30),
              delay: Duration(milliseconds: 100 * i),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                decoration: BoxDecoration(
                  color: AppColors.white2,
                  border: Border.all(color: AppColors.border222),
                ),
                child: Column(
                  children: [
                    Icon(_items[i].icon, size: 48, color: AppColors.primary),
                    const SizedBox(height: 24),
                    Text(
                      _items[i].title,
                      textAlign: TextAlign.center,
                      style: AppText.body(
                        20,
                        color: AppColors.white,
                        weight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _items[i].text,
                      textAlign: TextAlign.center,
                      style: AppText.body(16, color: AppColors.gray9c),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
