package com.example.doomguard

import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream

class MainActivity : FlutterFragmentActivity() {

    private val ICON_CHANNEL = "com.example.doomguard/app_icons"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ICON_CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "getAppIcon") {
                    val packageName = call.argument<String>("package_name") ?: ""
                    try {
                        val pm = applicationContext.packageManager
                        val drawable = pm.getApplicationIcon(packageName)
                        val bytes = drawableToBytes(drawable)
                        result.success(bytes)
                    } catch (e: Exception) {
                        result.success(null) // app not installed, return null gracefully
                    }
                } else {
                    result.notImplemented()
                }
            }
    }

    private fun drawableToBytes(drawable: Drawable): ByteArray {
        val bitmap = if (drawable is BitmapDrawable && drawable.bitmap != null) {
            drawable.bitmap
        } else {
            val w = drawable.intrinsicWidth.coerceAtLeast(1)
            val h = drawable.intrinsicHeight.coerceAtLeast(1)
            val bmp = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }
}