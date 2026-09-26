import '../../l10n/app_localizations.dart';
import 'api_exception.dart';

extension ApiExceptionText on ApiException {
  String localized(AppLocalizations l10n) => switch (failure) {
        ApiFailure.unreachable => l10n.errorUnreachable,
        ApiFailure.timeout => l10n.errorTimeout,
        ApiFailure.cancelled => l10n.errorCancelled,
        ApiFailure.validation => l10n.errorValidation,
        ApiFailure.notFound => l10n.errorNotSupported,
        ApiFailure.server => l10n.errorServer,
        ApiFailure.unknown => l10n.errorGenericTitle,
      };
}
