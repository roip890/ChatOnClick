package com.aptenobytes.chatonclick

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.PluginRegistrantCallback
//import io.flutter.plugins.androidalarmmanager.AlarmService
//import io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin
import com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin
import be.tramckrijte.workmanager.WorkmanagerPlugin

class Application : FlutterApplication(), PluginRegistrantCallback {
    override fun onCreate() {
        super.onCreate()
//        AlarmService.setPluginRegistrant(this)
        BackgroundFetchPlugin.setPluginRegistrant(this)
    }

    override fun registerWith(registry: PluginRegistry) {
//        LauncherPlugin.registerWith(registry.registrarFor("com.aptenobytes/launcher_plugin"))
//        AndroidAlarmManagerPlugin.registerWith(registry.registrarFor("io.flutter.plugins.androidalarmmanager.AndroidAlarmManagerPlugin"))
        BackgroundFetchPlugin.registerWith(registry.registrarFor("com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin"))
        WorkmanagerPlugin.setPluginRegistrantCallback(this)
    }
}
