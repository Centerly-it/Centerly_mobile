/// Build-time activation only after the completion package is approved/deployed.
/// Defaults false. Does not bypass database permissions or select another backend.
class CompletionContracts {
  CompletionContracts._();
  static const enabled = bool.fromEnvironment('CENTERLY_COMPLETION_CONTRACTS');
}
