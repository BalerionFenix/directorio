sealed class ErrorState {}

/// Muestra el error recibido por la URL.
class ErrorInitial extends ErrorState {
  final String message;

  ErrorInitial(this.message);
}

/// El usuario presionó "Reintentar": spinner dentro del botón.
class ErrorRetrying extends ErrorState {
  final String message;

  ErrorRetrying(this.message);
}

/// Listo para volver a la vista que falló, que cargará de nuevo.
class ErrorRetryReady extends ErrorState {
  final String returnPath;

  ErrorRetryReady(this.returnPath);
}
