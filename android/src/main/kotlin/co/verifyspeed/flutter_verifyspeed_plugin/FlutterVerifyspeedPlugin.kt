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

    when (call.method) {
      "startVerification" -> {
        val clientKey: String = arguments!!["clientKey"] as String
        VerifySpeed.init(activity!!)
        VerifySpeed.setClientKey(clientKey)

        val redirectToStore: Boolean? = arguments["redirectToStore"] as Boolean?
        val type: VerifySpeedMethodType = if (arguments["type"] as String == "telegram-message") {
          VerifySpeedMethodType.Telegram
        } else if (arguments["type"] as String == "whatsapp-message") {
          VerifySpeedMethodType.WhatsApp
        } else {
          throw VerifySpeedError(
            message = "Invalid type",
            type = VerifySpeedErrorType.NotFoundVerificationMethod,
          )
        }

        GlobalScope.launch {
          VerifySpeed.startVerification(
            callBackListener = object : VerifySpeedListener {
              override fun onSuccess(token: String) {
                result.success(mapOf("token" to token))
              }

              override fun onFail(error: VerifySpeedError) {
                result.success(
                  mapOf(
                    "error" to error.message,
                    "errorType" to error.type.name,
                  )
                )
              }
            },
            type,
            redirectToStore = redirectToStore ?: true,
          )
        }
      }

      "startVerificationWithDeepLink" -> {
        val deepLink: String = arguments!!["deepLink"] as String
        val verificationName: String = arguments["verificationName"] as String
        val verificationKey: String = arguments["verificationKey"] as String
        val redirectToStore: Boolean? = arguments["redirectToStore"] as Boolean?
        VerifySpeed.init(activity!!)

        VerifySpeed.startVerificationWithDeeplink(
          callBackListener = object : VerifySpeedListener {
            override fun onSuccess(token: String) {
              result.success(mapOf("token" to token))
            }

            override fun onFail(error: VerifySpeedError) {
              result.success(
                mapOf(
                  "error" to error.message,
                  "errorType" to error.type.name,
                )
              )
            }
          },
          verificationKey = verificationKey,
          deepLink = deepLink,
          methodName = verificationName,
          redirectToStore = redirectToStore ?: true,
        )
      }

      "notifyOnResumed" -> {
        GlobalScope.launch {
          VerifySpeed.notifyOnResumed()
        }
      }

      "getUiFromApi" -> {
        val clientKey: String = arguments!!["clientKey"] as String
        VerifySpeed.setClientKey(clientKey)

        GlobalScope.launch {
          try {
            val response = VerifySpeed.getUiFromApi()
            result.success(response)
          } catch (error : VerifySpeedError){
            result.error(
              error.type.name,
              error.message,
              error.stackTrace.toString()
            )
          }
        }
      }

      "checkInterruptedSession" -> {
        GlobalScope.launch {
          VerifySpeed.init(activity!!)

          VerifySpeed.checkInterruptedSession(
            callBackListener = object : VerifySpeedListener {
              override fun onSuccess(token: String) {
                result.success(mapOf("token" to token))
              }

              override fun onFail(error: VerifySpeedError) {
                result.success(
                  mapOf(
                    "error" to error.message,
                    "errorType" to error.type.name,
                  )
                )
              }
            },
          )
        }
      }
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
