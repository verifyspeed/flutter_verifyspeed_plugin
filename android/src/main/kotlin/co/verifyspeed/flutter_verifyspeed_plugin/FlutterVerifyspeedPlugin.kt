package co.verifyspeed.flutter_verifyspeed_plugin

import android.app.Activity
import co.verifyspeed.androidlibrary.VerifySpeed
import co.verifyspeed.androidlibrary.VerifySpeedError
import co.verifyspeed.androidlibrary.VerifySpeedErrorType
import co.verifyspeed.androidlibrary.VerifySpeedListener
import co.verifyspeed.androidlibrary.VerifySpeedMethodType
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import java.lang.ref.WeakReference

/** FlutterVerifyspeedPlugin */
class FlutterVerifyspeedPlugin: FlutterPlugin, MethodCallHandler, ActivityAware{
  private lateinit var channel: MethodChannel
  private val activity get() = activityReference.get()
  private var activityReference = WeakReference<Activity>(null)

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "verifyspeed_channel")
    channel.setMethodCallHandler(this)
  }

  @OptIn(DelicateCoroutinesApi::class)
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    val arguments = call.arguments as HashMap<*, *>?
    if (activity == null) {
      result.success(mapOf("error" to "Activity not found", "errorType" to VerifySpeedErrorType .ActivityNotSet))

      return
    }

    when (call.method) {
      "verifyPhoneNumberWithDeepLink" -> {
        handleException({
          val deepLink = arguments!!["deepLink"] as String
          val verificationKey = arguments["verificationKey"] as String
          val redirectToStore = arguments["redirectToStore"] as? Boolean ?: true

          VerifySpeed.init(activity!!)

          VerifySpeed.verifyPhoneNumberWithDeepLink(
            deeplink = deepLink,
            verificationKey = verificationKey,
            redirectToStore = redirectToStore,
            callBackListener = getVerificationListener(result),
          )
        },
          result
        )
      }

      "verifyPhoneNumberWithOtp" -> {
        handleException(
          {
            val verificationKey = arguments!!["verificationKey"] as String
            val phoneNumber = arguments["phoneNumber"] as String

            GlobalScope.launch {
              VerifySpeed.verifyPhoneNumberWithOtp(
                phoneNumber = phoneNumber,
                verificationKey = verificationKey,
              )

              result.success(null)
            }
          },
          result
        )
      }

      "notifyOnResumed" -> {
        handleException(
          {
            GlobalScope.launch {
              VerifySpeed.notifyOnResumed()
            }
          },
          result
        )
      }

      "validateOtp" -> {
        handleException(
          {
            val verificationKey: String = arguments!!["verificationKey"] as String
            val otpCode: String = arguments["otpCode"] as String

            VerifySpeed.init(activity!!)

            GlobalScope.launch {
              VerifySpeed.validateOTP(
                otpCode = otpCode,
                verificationKey = verificationKey,
                callBackListener = getVerificationListener(result),
              )
            }
          },
          result,
        )
      }

      "getUiFromApi" -> {
        handleException({
          val clientKey = arguments!!["clientKey"] as String

          VerifySpeed.setClientKey(clientKey)

          GlobalScope.launch {
            val response = VerifySpeed.getUiFromApi()

            result.success(response)
          }
        }, result)
      }

      "checkInterruptedSession" -> {
        handleException({
          GlobalScope.launch {
            VerifySpeed.init(activity!!)

            VerifySpeed.checkInterruptedSession(
              callBackListener = getVerificationListener(result),
            )
          }
        }, result)
      }
    }
  }

  private fun getVerificationListener(result: MethodChannel.Result): VerifySpeedListener {
    return object : VerifySpeedListener {
      override fun onSuccess(token: String) {
        result.success(mapOf("token" to token))
      }

      override fun onFail(error: VerifySpeedError) {
        result.success(mapOf("error" to error.message, "errorType" to error.type.name))
      }
    }
  }

  private fun handleException(func: () -> Unit, result: MethodChannel.Result) {
    try {
      func()
    } catch (e: VerifySpeedError) {
      result.success(mapOf("error" to e.message, "errorType" to e.type.name))
    } catch (e: Exception) {
      result.success(mapOf("error" to e.message, "errorType" to "Unknown"))
    }
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activityReference = WeakReference(binding.activity)
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {
    onDetachedFromActivity()
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
    onAttachedToActivity(binding)
  }

  override fun onDetachedFromActivity() {
    activityReference.clear()
    channel.setMethodCallHandler(null)
  }
}
