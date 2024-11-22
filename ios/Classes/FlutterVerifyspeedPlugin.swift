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
        
        switch call.method {
        case "verifyPhoneNumberWithDeepLink":
            let deeplink = arguments?["deepLink"] as! String
            let verificationKey = arguments?["verificationKey"] as! String
            let redirectToStore = arguments?["redirectToStore"] as? Bool ?? true
            
            let listener = VerifySpeedListenerHandler(result: result)
            
            VerifySpeed.shared.verifyPhoneNumberWithDeepLink(
                deeplink: deeplink,
                verificationKey: verificationKey,
                redirectToStore: redirectToStore,
                callBackListener: listener
            )
            
        case "verifyPhoneNumberWithOtp":
            let phoneNumber = arguments?["phoneNumber"] as! String
            let verificationKey = arguments?["verificationKey"] as! String
            
            VerifySpeed.shared.verifyPhoneNumberWithOtp(
                phoneNumber: phoneNumber,
                verificationKey: verificationKey
            ) { response in
                switch response {
                case .success:
                    result(nil)
                    break
                    
                case .failure(let error):
                    result(["error" : error.message, "errorType" : error.type.name])
                    break
                }
            }
            
        case "validateOtp":
            let otpCode = arguments?["otpCode"] as! String
            let verificationKey = arguments?["verificationKey"] as! String
            
            let listener = VerifySpeedListenerHandler(result: result)
            
            VerifySpeed.shared.validateOTP(
                otpCode: otpCode,
                verificationKey: verificationKey,
                callBackListener: listener
            )
            
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
