import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Carrega as fontes reais do app antes dos testes. Sem isso, o Flutter usa
/// uma fonte de teste bem mais larga e o layout não corresponde ao celular.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await _loadFont('BebasNeue', ['assets/fonts/BebasNeue-Regular.ttf']);
  await _loadFont('Rajdhani', [
    'assets/fonts/Rajdhani-Regular.ttf',
    'assets/fonts/Rajdhani-Medium.ttf',
    'assets/fonts/Rajdhani-SemiBold.ttf',
    'assets/fonts/Rajdhani-Bold.ttf',
  ]);
  await _loadFont(
    'packages/lucide_icons_flutter/Lucide',
    ['packages/lucide_icons_flutter/assets/lucide.ttf'],
  );

  await testMain();
}

Future<void> _loadFont(String family, List<String> assets) async {
  final loader = FontLoader(family);
  for (final asset in assets) {
    loader.addFont(rootBundle.load(asset));
  }
  await loader.load();
}
