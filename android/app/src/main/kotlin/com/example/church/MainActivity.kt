package com.example.church

import android.view.WindowManager.LayoutParams
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Prevent screenshots and screen recording for security
        window.addFlags(LayoutParams.FLAG_SECURE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.abyssiniasoftware.church/security").setMethodCallHandler { call, result ->
            when (call.method) {
                "enableSecureMode" -> {
                    window.addFlags(LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                "disableSecureMode" -> {
                    window.clearFlags(LayoutParams.FLAG_SECURE)
                    result.success(null)
                }
                "isDeviceRooted" -> result.success(false)
                else -> result.notImplemented()
            }
        }
    }
}
