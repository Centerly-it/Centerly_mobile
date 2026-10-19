/// Approved package through 202610190010 deployed and verified on centerly-dev.
/// Override false only when targeting a backend without these pinned contracts.
class CompletionContracts {
  CompletionContracts._();
  static const enabled = bool.fromEnvironment(
    'CENTERLY_COMPLETION_CONTRACTS',
    defaultValue: true,
  );
}
