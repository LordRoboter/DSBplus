package com.plos.planner

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.os.PowerManager

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.plos.planner/battery_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL
        ).setMethodCallHandler { call, result ->

            when (call.method) {
                "openBatterySettings" -> {
                    try {
                        val intent = Intent(
                            Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                            Uri.parse("package:$packageName")
                        )

                        startActivity(intent)
                        result.success(null)
                    } catch (e: Exception) {
                        result.error(
                            "BATTERY_SETTINGS_ERROR",
                            "Could not open battery settings",
                            e.message
                        )
                    }
                }

                "isBatteryOptimizationDisabled" -> {
                    val powerManager =
                        getSystemService(POWER_SERVICE) as PowerManager

                    result.success(
                        powerManager.isIgnoringBatteryOptimizations(packageName)
                    )
                }

                else -> result.notImplemented()
            }
        }
    }
}