/// Modelos equivalentes às interfaces `Appointment` e `User` do App.tsx.
library;

enum AppointmentStatus { confirmed, pending }

class Appointment {
  const Appointment({
    required this.id,
    required this.clientName,
    required this.phone,
    required this.service,
    required this.date,
    required this.time,
    required this.status,
  });

  final String id;
  final String clientName;
  final String phone;
  final String service;

  /// Data no formato AAAA-MM-DD (mesmo valor do input type="date").
  final String date;

  /// Horário no formato HH:mm.
  final String time;
  final AppointmentStatus status;

  /// Converte o JSON da API (Agedamentocontrolador). O nome e o telefone do
  /// cliente só vêm na lista completa (admin); nos demais casos usa os do usuário.
  factory Appointment.fromApi(Map<String, dynamic> json, AppUser user) {
    return Appointment(
      id: '${json['id']}',
      clientName: json['clienteNome'] as String? ?? user.name,
      phone: json['clienteTelefone'] as String? ?? user.telefone,
      service: json['servicos'] as String,
      date: (json['data'] as String).substring(0, 10),
      time: (json['dataHorainicio'] as String).substring(0, 5),
      status: json['situacao'] == 'confirmado'
          ? AppointmentStatus.confirmed
          : AppointmentStatus.pending,
    );
  }

  Appointment copyWith({AppointmentStatus? status}) {
    return Appointment(
      id: id,
      clientName: clientName,
      phone: phone,
      service: service,
      date: date,
      time: time,
      status: status ?? this.status,
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.telefone,
    required this.isAdmin,
  });

  final int id;
  final String name;
  final String email;
  final String telefone;
  final bool isAdmin;
}

/// Serviço oferecido, como vem da API (ServicosControlador). O administrador
/// altera a lista na aba ADMIN > SERVIÇOS; o início e o agendamento leem dela.
class Servico {
  const Servico({
    required this.id,
    required this.nome,
    required this.preco,
    required this.duracaoMinutos,
  });

  final int id;
  final String nome;
  final double preco;
  final int duracaoMinutos;

  factory Servico.fromApi(Map<String, dynamic> json) {
    return Servico(
      id: (json['id'] as num).toInt(),
      nome: json['nameServico'] as String,
      preco: (json['preco'] as num).toDouble(),
      duracaoMinutos: (json['duracaoMinutos'] as num).toInt(),
    );
  }
}

/// "R$ 45" ou "R$ 47,50", igual ao formatarPreco do site.
String formatPreco(double preco) => preco == preco.roundToDouble()
    ? 'R\$ ${preco.toInt()}'
    : 'R\$ ${preco.toStringAsFixed(2).replaceAll('.', ',')}';
