import '../../../data/models/contact.dart';

sealed class ContactDetailState {}

class ContactDetailInitial extends ContactDetailState {}

/// Cargando: skeleton de la ficha.
class ContactDetailLoading extends ContactDetailState {}

/// Ficha completa del contacto.
class ContactDetailSuccess extends ContactDetailState {
  final Contact contact;
  final bool isFavorite;

  ContactDetailSuccess({required this.contact, required this.isFavorite});
}

/// El id de la URL no existe (ej. /contacts/40) o no es un número.
class ContactDetailNotFound extends ContactDetailState {}

/// Falló la carga: la vista redirige a /error con este mensaje.
class ContactDetailError extends ContactDetailState {
  final String message;

  ContactDetailError(this.message);
}
