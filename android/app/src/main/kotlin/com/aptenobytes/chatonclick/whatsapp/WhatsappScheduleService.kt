package com.aptenobytes.chatonclick.whatsapp

import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import androidx.core.app.NotificationCompat
import com.aptenobytes.chatonclick.R


class WhatsappScheduleService : Service() {
    override fun onCreate() {
        super.onCreate()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val builder = NotificationCompat.Builder(this, "messages")
                    .setContentText("Chat On Click")
                    .setContentTitle("Scheduling whatsapp messages")
                    .setSmallIcon(R.mipmap.ic_launcher)
            startForeground(101, builder.build())
        }
    }

    override fun onBind(intent: Intent): IBinder? {
        return null
    }
}
