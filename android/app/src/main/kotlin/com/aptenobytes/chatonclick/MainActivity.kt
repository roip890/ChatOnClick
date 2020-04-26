package com.aptenobytes.chatonclick

import android.accessibilityservice.AccessibilityService
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.text.TextUtils
import androidx.annotation.NonNull
import com.aptenobytes.chatonclick.whatsapp.WhatsappAccessibilityService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity() {

    private var startString: String? = null
    private var linksReceiver: BroadcastReceiver? = null
    companion object {
        private const val DEEP_LINK_CHANNEL = "com.aptenobytes/deep_link_cnannel"
        private const val DEEP_LINK_EVENTS = "com.aptenobytes/deep_link_events"
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
//        flutterEngine.plugins.add(LauncherPlugin())
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // splash screen
        val flutter_native_splash = true
        var originalStatusBarColor = 0
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            originalStatusBarColor = window.statusBarColor
    //        window.statusBarColor = Color.parseColor("0xff118971")
            window.statusBarColor = Color.parseColor("#ff118971")
        }
        val originalStatusBarColorFinal = originalStatusBarColor

        // accessibility service
        if (!isAccessibilityOn(context, WhatsappAccessibilityService::class.java)) {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            context.startActivity(intent)
        }

        val data = intent.data
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, DEEP_LINK_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "initialLink") {
                if (startString != null) {
                    result.success(startString)
                }
            }
        }
        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, DEEP_LINK_EVENTS).setStreamHandler(
                object : EventChannel.StreamHandler {
                    override fun onListen(args: Any?, events: EventChannel.EventSink) {
                        linksReceiver = createChangeReceiver(events)
                    }

                    override fun onCancel(args: Any?) {
                        linksReceiver = null
                    }
                }
        )
        if (data != null) {
            startString = data.toString()
            linksReceiver?.onReceive(this.applicationContext, intent)
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        if (intent.action === android.content.Intent.ACTION_VIEW) {
            linksReceiver?.onReceive(this.applicationContext, intent)
        }
    }

    private fun createChangeReceiver(events: EventChannel.EventSink): BroadcastReceiver {
        return object : BroadcastReceiver() {
            override fun onReceive(context: Context, intent: Intent) { // NOTE: assuming intent.getAction() is Intent.ACTION_VIEW
                val dataString = intent.dataString
                if (dataString == null) {
                    events.error("UNAVAILABLE", "Link unavailable", null)
                } else {
                    events.success(dataString)
                }
            }
        }
    }

    private fun isAccessibilityOn(context: Context, clazz: Class<out AccessibilityService?>): Boolean {
        var accessibilityEnabled = 0
        val service = context.packageName + "/" + clazz.canonicalName
        try {
            accessibilityEnabled = Settings.Secure.getInt(context.applicationContext.contentResolver, Settings.Secure.ACCESSIBILITY_ENABLED)
        } catch (ignored: Settings.SettingNotFoundException) {
        }
        val colonSplitter: TextUtils.SimpleStringSplitter = TextUtils.SimpleStringSplitter(':')
        if (accessibilityEnabled == 1) {
            val settingValue: String = Settings.Secure.getString(context.applicationContext.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
            if (settingValue != null) {
                colonSplitter.setString(settingValue)
                while (colonSplitter.hasNext()) {
                    val accessibilityService: String = colonSplitter.next()
                    if (accessibilityService.equals(service, ignoreCase = true)) {
                        return true
                    }
                }
            }
        }
        return false
    }

}