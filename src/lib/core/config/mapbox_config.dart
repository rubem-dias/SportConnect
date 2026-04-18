/// Configuração do Mapbox para o SportConnect.
///
/// Tokens são injetados via --dart-define-from-file=.env.json em build time.
/// Nunca hardcode tokens no código-fonte.
///
/// Setup:
/// 1. Copie .env.json.example → .env.json e preencha com seu token público (pk.ey...)
/// 2. Copie android/secrets.properties.example → android/secrets.properties
///    e preencha com seu token secreto (sk.ey...)
/// 3. Os comandos `make dev-usb` / `make dev` já passam --dart-define-from-file automaticamente
class MapboxConfig {
  MapboxConfig._();

  /// Token público do Mapbox (pk.ey...) — injetado via --dart-define-from-file=.env.json.
  static const String publicToken = String.fromEnvironment('MAPBOX_PUBLIC_TOKEN');

  /// URI do estilo para modo claro.
  static const String styleLight = 'mapbox://styles/mapbox/streets-v12';

  /// URI do estilo para modo escuro.
  static const String styleDark = 'mapbox://styles/mapbox/dark-v11';
}
