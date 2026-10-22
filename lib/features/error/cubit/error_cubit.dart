import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_dimens.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_strings.dart';
import 'error_state.dart';

class ErrorCubit extends Cubit<ErrorState> {
  final String _message;
  final String _returnPath;

  ErrorCubit({String? message, String? from})
    : this._(
        (message == null || message.trim().isEmpty)
            ? AppStrings.errorUnknown
            : message,
        AppRoutes.safeReturnPath(from),
      );

  ErrorCubit._(String message, this._returnPath)
    : _message = message,
      super(ErrorInitial(message));

  Future<void> retry() async {
    if (state is! ErrorInitial) return;
    emit(ErrorRetrying(_message));
    // Deja ver el spinner antes de volver a la vista que falló.
    await Future.delayed(AppDurations.normal);
    if (!isClosed) emit(ErrorRetryReady(_returnPath));
  }
}
