/// Owner-separated hosted environments; these references are public identifiers.
class BackendProjects {
  BackendProjects._();
  static const development = 'yfeubomyglmhuwizaqoj';
  static const production = 'ohhwccwwwxfmwpfypfyf';
  static const productionHost = '$production.supabase.co';
  static bool accepts(String environment, String host) =>
      environment == 'production'
      ? host == productionHost
      : host != productionHost;
}
