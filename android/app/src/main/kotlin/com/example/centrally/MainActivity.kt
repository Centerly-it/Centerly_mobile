package com.example.centrally

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var updates: UpdateChannel? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        updates = UpdateChannel(this, flutterEngine.dartExecutor.binaryMessenger)
    }
    override fun cleanUpFlutterEngine(flutterEngine: FlutterEngine) {
        updates?.dispose()
        updates = null
        super.cleanUpFlutterEngine(flutterEngine)
    }
}
