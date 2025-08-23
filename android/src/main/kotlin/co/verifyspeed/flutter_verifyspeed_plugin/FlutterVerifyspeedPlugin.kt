package co.verifyspeed.flutter_verifyspeed_plugin

import android.app.Activity
import co.verifyspeed.android.VerifySpeed
import co.verifyspeed.android.VerifySpeedError
import co.verifyspeed.android.VerifySpeedErrorType
import co.verifyspeed.android.VerifySpeedListener
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.future.await
import kotlinx.coroutines.launch
import java.lang.ref.WeakReference

/** FlutterVerifySpeedPlugin */
class FlutterVerifyspeedPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private val activity get() = activityReference.get()
    private var activityReference = WeakReference<Activity>(null)

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "verifyspeed_channel")

        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        val arguments = call.arguments as HashMap<*, *>?
        if (activity == null) {
            result.success(
                mapOf(
                    "error" to "Activity not found",
                    "errorType" to VerifySpeedErrorType.ActivityNotSet
                )
            )

            return
        }

        when (call.method) {
            "initialize" -> {
                handleException({
                    val clientKey = arguments!!["clientKey"] as String

                    VerifySpeed.setClientKey(clientKey)

                    val methods = VerifySpeed.initialize().await()

                    val methodsJson = """
              {
                "availableMethods": ${
                        methods.map { method ->
                            """{"methodName":"${method.methodName}","displayName":"${method.displayName}"}"""
                        }
                    }
              }
            """.trimIndent()

                    result.success(methodsJson)
                }, result)
            }


            "verifyPhoneNumberWithDeepLink" -> {
                handleException(
                    {
                        val deepLink = arguments!!["deepLink"] as String
                        val verificationKey = arguments["verificationKey"] as String
                        val redirectToStore = arguments["redirectToStore"] as? Boolean ?: true

                        VerifySpeed.setActivity(activity!!)

                        VerifySpeed.verifyPhoneNumberWithDeepLink(
                            deepLink,
                            verificationKey,
                            redirectToStore,
                            getVerificationListener(result),
                        )
                    },
                    result
                )
            }

            "verifyPhoneNumberWithOtp" -> {
                handleException({
                    val verificationKey = arguments!!["verificationKey"] as String
                    val phoneNumber = arguments["phoneNumber"] as String

                    VerifySpeed.verifyPhoneNumberWithOtp(
                        phoneNumber,
                        verificationKey,
                    ).await()

                    result.success(null)
                }, result)
            }

            "validateOtp" -> {
                handleException(
                    {
                        val verificationKey: String = arguments!!["verificationKey"] as String
                        val otpCode: String = arguments["otpCode"] as String

                        VerifySpeed.setActivity(activity!!)

                        VerifySpeed.validateOTP(
                            otpCode,
                            verificationKey,
                            getVerificationListener(result),
                        ).await()
                    },
                    result,
                )
            }

            "notifyOnResumed" -> {
                handleException(
                    { VerifySpeed.notifyOnResumed() },
                    result
                )
            }

            "checkInterruptedSession" -> {
                handleException({
                    VerifySpeed.setActivity(activity!!)

                    VerifySpeed.checkInterruptedSession { token ->
                        result.success(mapOf("token" to token))
                    }.await()
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

    private fun handleException(func: suspend () -> Unit, result: MethodChannel.Result) {
        CoroutineScope(Dispatchers.Main).launch {
            try {
                func()
            } catch (e: VerifySpeedError) {
                result.success(mapOf("error" to e.message, "errorType" to e.type.name))
            } catch (e: Exception) {
                result.success(mapOf("error" to e.message, "errorType" to "Unknown"))
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
