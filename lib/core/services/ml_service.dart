// Conditional export: Use web implementation on web, mobile implementation on native platforms
export 'ml_service_web.dart' if (dart.library.io) 'ml_service_mobile.dart';
