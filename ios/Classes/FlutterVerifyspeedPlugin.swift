import Flutter
import UIKit
import VerifySpeed_IOS

public class FlutterVerifyspeedPlugin: NSObject, FlutterPlugin {
    
    private var channel: FlutterMethodChannel?
    private var eventChannel: FlutterEventChannel?
    private var navigationController: UINavigationController!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = FlutterVerifyspeedPlugin()
        
        instance.channel = FlutterMethodChannel(name: "verifyspeed_channel", binaryMessenger: registrar.messenger())
        registrar.addMethodCallDelegate(instance, channel: instance.channel!)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String: Any]
        let redirectToStore = arguments?["redirectToStore"] as? Bool ?? true
        
        switch call.method {
        case "startVerification":
            let clientKey = arguments?["clientKey"] as! String
            let typeString = arguments?["type"] as! String
            let type: VerifySpeedMethodType
            let listener = VerifySpeedListenerHandler(result: result)

            if typeString == "telegram-message" {
                type = .Telegram
            } else if typeString == "whatsapp-message" {
                type = .WhatsApp
            } else {
                result(["error" : "Invalid type", "errorType" : "NotFoundVerificationMethod"])
                return
            }
            
            VerifySpeed.shared.setClientKey(clientKey)
            do {
                try VerifySpeed.shared.startVerification(
                    callBackListener: listener,
                    verifySpeedMethodType: type,
                    redirectToStore: redirectToStore
                )
            } catch {
                result(["error" : "Something went wrong", "errorType" : "Unknown"])
            }
            
        case "startVerificationWithDeepLink":
            let deepLink = arguments?["deepLink"] as! String
            let verificationName = arguments?["verificationName"] as! String
            let verificationKey = arguments?["verificationKey"] as! String

            do {
                let listener = VerifySpeedListenerHandler(result: result)

                try VerifySpeed.shared.startVerificationWithDeepLink(
                    callBackListener: listener,
                    deepLink: deepLink,
                    verificationKey: verificationKey,
                    methodName: verificationName,
                    redirectToStore: redirectToStore
                )
            } catch {
                result(FlutterError(code: "ERROR_OCCURRED", message: "Error occurred while startVerificationWithDeepLink", details: nil))
            }
            
            
        case "notifyOnResumed":
            VerifySpeed.shared.notifyOnResumed()
            
        case "getUiFromApi":
            let clientKey = arguments?["clientKey"] as! String
            
            VerifySpeed.shared.setClientKey(clientKey)
            VerifySpeed.shared.getUIFromAPI(){ data in
                result(data)
            }
            
        case "checkInterruptedSession":
            let listener = VerifySpeedListenerHandler(result: result)

            VerifySpeed.shared.checkInterruptedSession(callBackListener: listener)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

class VerifySpeedListenerHandler : VerifySpeedListener {
    init(result: @escaping FlutterResult) {
        self.result = result
    }
    
    let result: FlutterResult
    
    func onFail(error: VerifySpeedError) {
        result(["error" : error.message, "errorType" : error.type.name])
    }
    
    func onSuccess(token: String) {
        result(["token" : token])
    }
}
