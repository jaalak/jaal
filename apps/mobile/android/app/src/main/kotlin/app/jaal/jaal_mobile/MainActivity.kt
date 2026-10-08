package app.jaal.jaal_mobile

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // "share jaal": tells Dart where Android keeps this app's own installer
        // so it can be passed phone to phone (Quick Share, Bluetooth, ...).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "jaal/app").setMethodCallHandler { call, result ->
            when (call.method) {
                "apkPath" -> result.success(applicationInfo.sourceDir)
                "version" -> {
                    val info = packageManager.getPackageInfo(packageName, 0)
                    result.success(info.versionName ?: "?")
                }
                else -> result.notImplemented()
            }
        }
    }
}
