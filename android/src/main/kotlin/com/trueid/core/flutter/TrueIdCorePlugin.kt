package com.trueid.core.flutter

import android.app.Activity
import androidx.activity.ComponentActivity
import com.trueid.sdk.selfie.CameraFacing
import com.trueid.sdk.selfie.CaptureMode
import com.trueid.sdk.selfie.ResultFormat
import com.trueid.sdk.selfie.SelfieCaptureCallback
import com.trueid.sdk.selfie.SelfieCaptureConfig
import com.trueid.sdk.selfie.SelfieCaptureError
import com.trueid.sdk.selfie.SelfieCaptureResult
import com.trueid.sdk.selfie.TrueIDSdk
import com.trueid.sdk.selfie.TrueIDSelfieCapture
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class TrueIdCorePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var pendingResult: Result? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "com.trueid.sdk.core/flutter")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "captureSelfie" -> handleCaptureSelfie(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        val secretKey = call.argument<String>("secretKey")
        val publishableKey = call.argument<String>("publishableKey")
        if (secretKey.isNullOrBlank() && publishableKey.isNullOrBlank()) {
            result.error("INVALID_ARGUMENT", "secretKey or publishableKey is required", null)
            return
        }

        val envName = call.argument<String>("environment") ?: "production"
        val customBaseUrl = call.argument<String>("customBaseUrl")

        val environment = when (envName) {
            "staging" -> TrueIDSdk.Environment.STAGING
            "custom" -> TrueIDSdk.Environment.CUSTOM
            else -> TrueIDSdk.Environment.PRODUCTION
        }

        try {
            TrueIDSdk.initialize(
                secretKey = secretKey,
                publishableKey = publishableKey,
                environment = environment,
                customBaseUrl = customBaseUrl,
            )
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun handleCaptureSelfie(call: MethodCall, result: Result) {
        val currentActivity = activity
        if (currentActivity !is ComponentActivity) {
            result.error("INCOMPATIBLE_ACTIVITY", "Activity must be a ComponentActivity", null)
            return
        }

        if (pendingResult != null) {
            result.error("ALREADY_ACTIVE", "A capture is already in progress", null)
            return
        }

        pendingResult = result

        val resultFormat = when (call.argument<String>("resultFormat") ?: "base64") {
            "byteArray" -> ResultFormat.BYTE_ARRAY
            "filePath" -> ResultFormat.FILE_PATH
            "all" -> ResultFormat.ALL
            else -> ResultFormat.BASE64
        }

        val config = SelfieCaptureConfig(
            captureMode = when (call.argument<String>("captureMode")) {
                "manual" -> CaptureMode.MANUAL
                else -> CaptureMode.AUTO
            },
            initialCamera = when (call.argument<String>("initialCamera")) {
                "back" -> CameraFacing.BACK
                else -> CameraFacing.FRONT
            },
            allowCameraSwitch = call.argument<Boolean>("allowCameraSwitch") ?: true,
            showFaceMesh = call.argument<Boolean>("showFaceMesh") ?: true,
            outputWidth = call.argument<Int>("outputWidth") ?: 600,
            outputHeight = call.argument<Int>("outputHeight") ?: 800,
            jpegQuality = call.argument<Int>("jpegQuality") ?: 94,
            burstFrameCount = call.argument<Int>("burstFrameCount") ?: 4,
            burstFrameDelayMs = (call.argument<Int>("burstFrameDelayMs") ?: 90).toLong(),
            resultFormat = resultFormat,
        )

        val callback = object : SelfieCaptureCallback {
            override fun onCaptured(captureResult: SelfieCaptureResult) {
                val map = hashMapOf<String, Any?>(
                    "base64" to captureResult.base64,
                    "filePath" to captureResult.filePath,
                    "burstFrames" to captureResult.burstFrames,
                )
                if (captureResult.imageBytes != null) {
                    map["imageBytes"] = captureResult.imageBytes!!.toList()
                }
                pendingResult?.success(map)
                pendingResult = null
            }

            override fun onCancelled() {
                pendingResult?.success(null)
                pendingResult = null
            }

            override fun onError(error: SelfieCaptureError) {
                pendingResult?.error("CAPTURE_ERROR", error.message, null)
                pendingResult = null
            }
        }

        TrueIDSelfieCapture.launch(currentActivity, config, callback)
    }
}
