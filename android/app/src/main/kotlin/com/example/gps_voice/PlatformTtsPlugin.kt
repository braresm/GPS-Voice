package com.example.gps_voice

import android.content.Context
import android.speech.tts.TextToSpeech
import android.speech.tts.UtteranceProgressListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import java.util.*

class PlatformTtsPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var textToSpeech: TextToSpeech? = null
    private var isInitialized = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "com.example.gps_voice/tts")
        context = flutterPluginBinding.applicationContext
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initializeTts" -> {
                initializeTts(result)
            }
            "speak" -> {
                val text = call.argument<String>("text")
                if (text != null) {
                    speak(text, result)
                } else {
                    result.error("INVALID_ARGUMENT", "Text cannot be null", null)
                }
            }
            "stop" -> {
                stop(result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initializeTts(result: Result) {
        if (isInitialized) {
            result.success(true)
            return
        }

        textToSpeech = TextToSpeech(context) { status ->
            if (status == TextToSpeech.SUCCESS) {
                val locale = Locale.US
                val languageResult = textToSpeech?.setLanguage(locale)
                if (languageResult == TextToSpeech.LANG_MISSING_DATA ||
                    languageResult == TextToSpeech.LANG_NOT_SUPPORTED) {
                    result.error("LANGUAGE_NOT_SUPPORTED", "Language not supported", null)
                } else {
                    isInitialized = true
                    result.success(true)
                }
            } else {
                result.error("INIT_FAILED", "Failed to initialize TTS", null)
            }
        }
    }

    private fun speak(text: String, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "TTS not initialized", null)
            return
        }

        textToSpeech?.setPitch(1.0f)
        textToSpeech?.setSpeechRate(0.5f)
        
        val utteranceId = UUID.randomUUID().toString()
        textToSpeech?.setOnUtteranceProgressListener(object : UtteranceProgressListener() {
            override fun onStart(utteranceId: String?) {
                if (utteranceId == utteranceId) {
                    result.success(true)
                }
            }

            override fun onDone(utteranceId: String?) {
                // Not needed for our implementation
            }

            override fun onError(utteranceId: String?) {
                if (utteranceId == utteranceId) {
                    result.error("SPEAK_ERROR", "Failed to speak", null)
                }
            }

            override fun onBeginSynthesis(utteranceId: String?, sampleRateInHz: Int, audioFormat: Int, channelCount: Int) {
                // Not needed for our implementation
            }
        })

        textToSpeech?.speak(text, TextToSpeech.QUEUE_FLUSH, null, utteranceId)
    }

    private fun stop(result: Result) {
        textToSpeech?.stop()
        result.success(true)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        textToSpeech?.stop()
        textToSpeech?.shutdown()
        textToSpeech = null
    }
} 