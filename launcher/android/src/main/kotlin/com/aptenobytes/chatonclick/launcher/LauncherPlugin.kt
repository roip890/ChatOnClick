package com.aptenobytes.chatonclick.launcher

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.PowerManager
import android.util.Log
import android.view.WindowManager
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry


class LauncherPlugin: FlutterPlugin, MethodChannel.MethodCallHandler {

  companion object {
    var context: Context? = null
    var launched : Boolean = false

    @JvmStatic
    var tag : String = ""

    @JvmStatic
    val key: String = "com.aptenobytes/launcher_plugin"

    @JvmStatic
    fun registerWith(registrar: PluginRegistry.Registrar) {
      val channel = MethodChannel(registrar.messenger(), key)
      context = registrar.activeContext()
      channel.setMethodCallHandler(LauncherPlugin())
    }
  }

  override fun onAttachedToEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(binding.binaryMessenger, key)
    context = binding.applicationContext
    channel.setMethodCallHandler(LauncherPlugin())
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
//    TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    when(call.method){
      "sendWhatsappMessage" -> {
        try {
          val powerManager: PowerManager = context!!.applicationContext
                  .getSystemService(Context.POWER_SERVICE) as PowerManager
          val wakeLock: PowerManager.WakeLock = powerManager.newWakeLock(
                  WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or
                          PowerManager.ACQUIRE_CAUSES_WAKEUP, context!!.packageName.toString() + ":Call")
          wakeLock.acquire(1*60*1000L /*1 minute*/)
          val number = call.argument<String>("number")!!
          val message = call.argument<String>("message")!!
          var url = "https://api.whatsapp.com/send?phone=$number"
          if (message != "") {
            url += "&text=$message"
          }
          val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
          browserIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
          context!!.startActivity(browserIntent)
          launched = true
        } catch (e: java.lang.Exception){
          Log.w("launcher",e.message)
          result.error("15",e.message, e.localizedMessage)
        } finally {
          result.success(launched)
        }
      }
      "launch" -> {
        try {
          val intent = Intent(context, LaunchActivity::class.java).apply {
            putExtra("route", "/")
            putExtra("destroy_engine_with_activity", true)
          }
          intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
          context!!.startActivity(intent)
          launched = true
        } catch (e: Exception){
          Log.w("launcher",e.message)
          result.error("12",e.message, e.localizedMessage)
        } finally {
          result.success(launched)
        }
      }
      else -> result.notImplemented()
    }
  }

}
