/// Configuração do Mapbox para o SportConnect.
///
/// O token público (pk.ey...) é seguro de distribuir no app — o Mapbox
/// permite restringi-lo por Bundle ID / package name no dashboard.
///
/// Passos para configurar:
/// 1. Acesse https://account.mapbox.com → Access Tokens
/// 2. Crie um token público com escopo padrão e restrinja ao bundle do app
/// 3. Substitua a string abaixo pelo token (pk.ey...)
/// 4. Para Android: coloque o token secreto (sk.ey...) em android/gradle.properties
/// 5. Para iOS: configure ~/.netrc com o token secreto (ver README)
class MapboxConfig {
  MapboxConfig._();

  /// Token público do Mapbox (pk.ey...).
  /// Exibido publicamente no binário — restrinja-o por bundle ID no dashboard.
  static const String publicToken =
      'pk.eyJ1IjoicmRzaWx2YTIyIiwiYSI6ImNtbzRxNzBpeDFqcnIydHB5NWozenFrYzEifQ.Os1Y-74kHxaONMQx6D1_og';

  /// URI do estilo para modo claro.
  static const String styleLight = 'mapbox://styles/mapbox/streets-v12';

  /// URI do estilo para modo escuro.
  static const String styleDark = 'mapbox://styles/mapbox/dark-v11';
}
