import Flutter
import AVFoundation

class PlatformTtsPlugin: NSObject, FlutterPlugin {
    private var synthesizer: AVSpeechSynthesizer?
    private var isInitialized = false
    
    static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "com.example.gps_voice/tts", binaryMessenger: registrar.messenger())
        let instance = PlatformTtsPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initializeTts":
            initializeTts(result: result)
        case "speak":
            if let args = call.arguments as? [String: Any],
               let text = args["text"] as? String {
                speak(text: text, result: result)
            } else {
                result(FlutterError(code: "INVALID_ARGUMENT",
                                  message: "Text cannot be null",
                                  details: nil))
            }
        case "stop":
            stop(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func initializeTts(result: @escaping FlutterResult) {
        if isInitialized {
            result(true)
            return
        }
        
        synthesizer = AVSpeechSynthesizer()
        isInitialized = true
        result(true)
    }
    
    private func speak(text: String, result: @escaping FlutterResult) {
        guard let synthesizer = synthesizer else {
            result(FlutterError(code: "NOT_INITIALIZED",
                              message: "TTS not initialized",
                              details: nil))
            return
        }
        
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.pitchMultiplier = 1.0
        utterance.rate = 0.5
        
        synthesizer.speak(utterance)
        result(true)
    }
    
    private func stop(result: @escaping FlutterResult) {
        synthesizer?.stopSpeaking(at: .immediate)
        result(true)
    }
} 