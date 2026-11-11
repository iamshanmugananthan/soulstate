package com.shanmugananthan.soulstate

import android.app.NotificationManager
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.content.pm.PackageManager
import android.content.res.Configuration
import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {

    private val channelName = "soulstate/app_icon"
    private val legacyChannelName = "soulstate/app_icon"
    private var channel: MethodChannel? = null
    private var legacyChannel: MethodChannel? = null
    private var wasNight: Boolean? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        try {
            window.decorView.filterTouchesWhenObscured = true
        } catch (_: Exception) {}
        NotificationStore.repairFor(applicationContext, buildVersion())
        WidgetRefreshReceiver.schedule(applicationContext)
        wasNight = WidgetConfig.isNight(applicationContext)
        HealthBridge.attach(this, MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HealthBridge.CHANNEL))
        HealthBridge.attach(this, MethodChannel(flutterEngine.dartExecutor.binaryMessenger, HealthBridge.LEGACY_CHANNEL))
        SoundBridge.attach(applicationContext, MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SoundBridge.CHANNEL))
        SoundBridge.attach(applicationContext, MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SoundBridge.LEGACY_CHANNEL))
        val handler = MethodChannel.MethodCallHandler { call, result ->
            when (call.method) {
                "setIcon" -> {
                    setIcon(call.argument<String>("icon") ?: "default")
                    result.success(true)
                }
                "setSecure" -> {
                    setSecure(call.argument<Boolean>("secure") ?: false)
                    result.success(true)
                }
                "dismissNotifications" -> {
                    val manager =
                        getSystemService(NOTIFICATION_SERVICE) as NotificationManager
                    call.argument<List<Int>>("ids")?.forEach { manager.cancel(it) }
                    result.success(true)
                }
                "consumeLaunchHabit" -> result.success(takeHabitId(intent))
                "consumeLaunchPage" -> result.success(takePage(intent))
                "openWidgetEditor" -> {
                    val kind = call.argument<String>("kind")
                    if (kind in listOf("habit", "today", "heatmap", "todos", "dashboard", "money", "meals")) {
                        startActivity(
                            Intent(this@MainActivity, WidgetConfigActivity::class.java)
                                .putExtra(WidgetConfigActivity.EXTRA_TEMPLATE, kind),
                        )
                    }
                    result.success(true)
                }
                "widgetPreview" -> result.success(widgetPreview(call.argument<String>("kind")))
                "pinWidget" -> {
                    val kind = call.argument<String>("kind")
                    result.success(pinWidget(kind))
                }
                else -> result.notImplemented()
            }
        }
        channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).apply {
            setMethodCallHandler(handler)
        }
        legacyChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, legacyChannelName).apply {
            setMethodCallHandler(handler)
        }
    }

    override fun onDestroy() {
        SoundBridge.detach()
        super.onDestroy()
    }

    override fun onConfigurationChanged(newConfig: Configuration) {
        super.onConfigurationChanged(newConfig)
        val night = (newConfig.uiMode and Configuration.UI_MODE_NIGHT_MASK) ==
            Configuration.UI_MODE_NIGHT_YES
        if (night == wasNight) return
        wasNight = night
        WidgetRefreshReceiver.refreshAll(applicationContext)
    }

    private fun setSecure(secure: Boolean) = runOnUiThread {
        if (secure) {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }
    }

    private fun buildVersion(): Long = try {
        val info = packageManager.getPackageInfo(packageName, 0)
        info.longVersionCode * 1000 + (info.lastUpdateTime % 1000)
    } catch (e: Exception) {
        0L
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        takeHabitId(intent)?.let {
            channel?.invokeMethod("openHabit", it)
            legacyChannel?.invokeMethod("openHabit", it)
        }
        takePage(intent)?.let {
            channel?.invokeMethod("openPage", it)
            legacyChannel?.invokeMethod("openPage", it)
        }
    }

    private fun takeHabitId(intent: Intent?): String? {
        val habitId = intent?.getStringExtra("openHabitId") ?: return null
        intent.removeExtra("openHabitId")
        return habitId
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (HealthBridge.onPermissionResult(requestCode, grantResults)) return
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
    }

    private fun takePage(intent: Intent?): String? {
        if (HealthBridge.isUsageIntent(intent)) return "health"
        val page = intent?.getStringExtra(EXTRA_OPEN_PAGE) ?: return null
        intent.removeExtra(EXTRA_OPEN_PAGE)
        return page
    }

    private fun widgetPreview(kind: String?): ByteArray? {
        val shot = when (kind) {
            "today" -> R.drawable.widget_preview_shot_today
            "heatmap" -> R.drawable.widget_preview_shot_heatmap
            "todos" -> R.drawable.widget_preview_shot_todos
            "habit" -> R.drawable.widget_preview_shot_week
            else -> return null
        }
        return try {
            resources.openRawResource(shot).use { it.readBytes() }
        } catch (_: Exception) {
            null
        }
    }

    private fun setIcon(key: String) {
        // Dynamic app icon switching is removed; the app permanently uses the letter icon.
    }

    private fun pinWidget(kind: String?): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return false
        val manager = getSystemService(AppWidgetManager::class.java) ?: return false
        if (!manager.isRequestPinAppWidgetSupported) return false

        val providerClass = when (kind) {
            "today" -> TodayWidgetProvider::class.java
            "habit" -> HabitWidgetProvider::class.java
            "heatmap" -> HeatmapWidgetProvider::class.java
            "todos" -> TodosWidgetProvider::class.java
            "dashboard" -> DashboardWidgetProvider::class.java
            "money" -> MoneyWidgetProvider::class.java
            "meals" -> MealsWidgetProvider::class.java
            else -> return false
        }
        val provider = ComponentName(this, providerClass)
        return try {
            manager.requestPinAppWidget(provider, null, null)
        } catch (_: Exception) {
            false
        }
    }
}
