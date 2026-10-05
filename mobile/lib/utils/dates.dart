/// Funções de data usadas pelas telas. Os valores seguem o formato do
/// input type="date" do site: AAAA-MM-DD.
library;

String _two(int value) => value.toString().padLeft(2, '0');

/// Converte uma data para AAAA-MM-DD.
String isoDate(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${_two(date.month)}-${_two(date.day)}';

/// Data de hoje no formato AAAA-MM-DD.
String todayIso() => isoDate(DateTime.now());

/// Lê uma data AAAA-MM-DD. Retorna null se o texto for inválido.
DateTime? parseIsoDate(String value) {
  final parts = value.split('-');
  if (parts.length != 3) return null;
  final year = int.tryParse(parts[0]);
  final month = int.tryParse(parts[1]);
  final day = int.tryParse(parts[2]);
  if (year == null || month == null || day == null) return null;
  return DateTime(year, month, day);
}

const _shortMonths = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun', //
  'jul', 'ago', 'set', 'out', 'nov', 'dez',
];

const _longMonths = [
  'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho', //
  'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
];

const _weekdays = [
  'segunda-feira', 'terça-feira', 'quarta-feira', 'quinta-feira', //
  'sexta-feira', 'sábado', 'domingo',
];

/// "05/10/2026", igual a toLocaleDateString("pt-BR").
String formatDateBr(String iso) {
  final date = parseIsoDate(iso);
  if (date == null) return iso;
  return '${_two(date.day)}/${_two(date.month)}/${date.year}';
}

/// "5 de out", igual ao formatDate do AdminPanel.
String formatDateAdmin(String iso) {
  final date = parseIsoDate(iso);
  if (date == null) return iso;
  return '${date.day} de ${_shortMonths[date.month - 1]}';
}

/// "segunda-feira, 5 de outubro de 2026", igual ao formatDate do Perfil.
String formatDateLong(String iso) {
  final date = parseIsoDate(iso);
  if (date == null) return iso;
  final weekday = _weekdays[date.weekday - 1];
  return '$weekday, ${date.day} de ${_longMonths[date.month - 1]} de ${date.year}';
}
