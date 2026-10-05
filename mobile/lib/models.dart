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

/// Dados enviados pelo formulário de agendamento
/// (equivalente a `Omit<Appointment, "id" | "status">`).
class NewAppointment {
  const NewAppointment({
    required this.clientName,
    required this.phone,
    required this.service,
    required this.date,
    required this.time,
  });

  final String clientName;
  final String phone;
  final String service;
  final String date;
  final String time;
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
