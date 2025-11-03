import Firebase
import FirebaseMessaging
import Flutter
import UIKit
import UserNotifications

@main
class AppDelegate: FlutterAppDelegate, MessagingDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    UNUserNotificationCenter.current().delegate = self
    Messaging.messaging().delegate = self

    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) {
      granted, error in
      // handle granted/error if needed
    }

    application.registerForRemoteNotifications()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
    _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    // Set APNs token for Firebase Messaging
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }

  // Firebase Messaging token callback
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    debugPrint("FCM token: \(String(describing: fcmToken))")
  }
}
