import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Leer API key desde variable de entorno del sistema
    // Configura la variable de entorno GOOGLE_MAPS_API_KEY antes de ejecutar:
    // export GOOGLE_MAPS_API_KEY=tu_api_key
    // flutter run
    guard let googleMapsApiKey = ProcessInfo.processInfo.environment["GOOGLE_MAPS_API_KEY"], !googleMapsApiKey.isEmpty else {
        fatalError("GOOGLE_MAPS_API_KEY no está configurada. Por favor, configura la variable de entorno antes de ejecutar la app.")
    }
    
    GMSServices.provideAPIKey(googleMapsApiKey)
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
