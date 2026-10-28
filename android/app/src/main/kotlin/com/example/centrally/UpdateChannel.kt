package com.example.centrally

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.StatFs
import android.provider.Settings
import androidx.core.content.FileProvider
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.BinaryMessenger
import java.util.concurrent.Executors

class UpdateChannel(private val activity: Activity, messenger: BinaryMessenger) {
    private val worker = Executors.newSingleThreadExecutor()
    private val channel = MethodChannel(messenger, "centerly/app_updates")
    init {
        channel.setMethodCallHandler { call, result ->
            try {
                when (call.method) {
                    "identity" -> result.success(mapOf(
                        "package_id" to activity.packageName,
                        "build" to UpdateArchive.build(UpdateArchive.installed(activity)),
                        "sdk" to Build.VERSION.SDK_INT,
                        "available_bytes" to StatFs(activity.cacheDir.path).availableBytes))
                    "canInstall" -> result.success(canInstall())
                    "openSettings" -> {
                        if (Build.VERSION.SDK_INT >= 26) activity.startActivity(Intent(
                            Settings.ACTION_MANAGE_UNKNOWN_APP_SOURCES,
                            Uri.parse("package:${activity.packageName}")))
                        result.success(null)
                    }
                    "install" -> {
                        val path = call.argument<String>("path") ?: error("UPDATE_INVALID")
                        val build = call.argument<Number>("build")?.toLong() ?: error("UPDATE_INVALID")
                        val size = call.argument<Number>("size")?.toLong() ?: error("UPDATE_INVALID")
                        val hash = call.argument<String>("sha256") ?: error("UPDATE_INVALID")
                        worker.execute {
                            try {
                                val file = UpdateArchive.verify(activity, path, build, size, hash)
                                activity.runOnUiThread {
                                    try {
                                        check(canInstall()) { "UPDATE_PERMISSION" }
                                        val uri = FileProvider.getUriForFile(activity,
                                            "${activity.packageName}.updates.provider", file)
                                        activity.startActivity(Intent(Intent.ACTION_VIEW)
                                            .setDataAndType(uri, "application/vnd.android.package-archive")
                                            .addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION))
                                        result.success(null)
                                    } catch (e: Exception) { fail(result, e) }
                                }
                            } catch (e: Exception) { activity.runOnUiThread { fail(result, e) } }
                        }
                    }
                    else -> result.notImplemented()
                }
            } catch (e: Exception) { fail(result, e) }
        }
    }
    private fun canInstall() = Build.VERSION.SDK_INT < 26 || activity.packageManager.canRequestPackageInstalls()
    private fun fail(result: MethodChannel.Result, error: Exception) {
        val allowed = setOf("UPDATE_INVALID", "UPDATE_CHECKSUM", "UPDATE_SIGNATURE", "UPDATE_PERMISSION", "UPDATE_INCOMPATIBLE")
        result.error(if (error.message in allowed) error.message!! else "UPDATE_INSTALL_FAILED", null, null)
    }
    fun dispose() { channel.setMethodCallHandler(null); worker.shutdown() }
}
