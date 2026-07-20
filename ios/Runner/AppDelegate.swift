import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var secureOverlay: UIView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    _setupScreenshotProtection()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func _setupScreenshotProtection() {
    // Mask window with a blur overlay when app goes to background
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(_appDidEnterBackground),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(_appWillEnterForeground),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
    // Detect screenshot attempts
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(_userDidTakeScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )
  }

  @objc private func _appDidEnterBackground() {
    guard let window = UIApplication.shared.windows.first else { return }
    let blur = UIBlurEffect(style: .dark)
    let overlay = UIVisualEffectView(effect: blur)
    overlay.frame = window.bounds
    overlay.tag = 9999
    window.addSubview(overlay)
    secureOverlay = overlay
  }

  @objc private func _appWillEnterForeground() {
    UIApplication.shared.windows.first?.viewWithTag(9999)?.removeFromSuperview()
    secureOverlay = nil
  }

  @objc private func _userDidTakeScreenshot() {
    // Log screenshot attempt — in production send to backend audit log
  }
}
