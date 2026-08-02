package com.muslim_ia.app

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val channelName = "muslimia/deeplinks"
    private var methodChannel: MethodChannel? = null
    private var initialLinkConsumed = false

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInitialLink" -> {
                    val link = if (initialLinkConsumed) null else intent?.dataString
                    initialLinkConsumed = true
                    result.success(link)
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        val link = intent.dataString
        if (link != null) {
            methodChannel?.invokeMethod("onNewIntentLink", link)
        }
    }
}
