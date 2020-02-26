package com.aptenobytes.chatonclick

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.os.Bundle

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private var startString: String? = null
    private var linksReceiver: BroadcastReceiver? = null

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    val flutter_native_splash = true
    var originalStatusBarColor = 0
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
        originalStatusBarColor = window.statusBarColor
//        window.statusBarColor = Color.parseColor("0xff118971")
        window.statusBarColor = Color.parseColor("#ff118971")
    }
    val originalStatusBarColorFinal = originalStatusBarColor

        val data = intent.data
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "initialLink") {
                if (startString != null) {
                    result.success(startString)
                }
            }
        }
        EventChannel(flutterEngine?.dartExecutor?.binaryMessenger, EVENTS).setStreamHandler(
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

    companion object {
        private const val CHANNEL = "poc.deeplink.flutter.dev/cnannel"
        private const val EVENTS = "poc.deeplink.flutter.dev/events"
    }
}