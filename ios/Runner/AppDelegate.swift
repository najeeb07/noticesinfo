import Flutter
import UIKit
// import FirebaseCore  // Temporarily disabled to test iOS 26 compatibility

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Firebase initialization temporarily disabled for iOS 26 beta testing
    // Firebase will be initialized from Dart code instead
    // if FirebaseApp.app() == nil {
    //   FirebaseApp.configure()
    // }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
