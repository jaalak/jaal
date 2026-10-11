package app.jaal.jaal_mobile

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

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
                // Settings → updates: open the system installer on a downloaded APK
                // (must sit in cache/updates/, see res/xml/update_paths.xml).
                "installApk" -> {
                    val file = File(call.argument<String>("path")!!)
                    val uri = FileProvider.getUriForFile(this, "$packageName.updates", file)
                    startActivity(
                        Intent(Intent.ACTION_VIEW)
                            .setDataAndType(uri, "application/vnd.android.package-archive")
                            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_ACTIVITY_NEW_TASK)
                    )
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
