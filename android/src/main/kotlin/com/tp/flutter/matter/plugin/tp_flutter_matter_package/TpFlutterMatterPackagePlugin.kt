package com.tp.flutter.matter.plugin.tp_flutter_matter_package

import android.R
import android.content.Context
import android.view.View
import android.widget.AdapterView
import android.widget.ArrayAdapter
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*

/** TpFlutterMatterPackagePlugin */
class TpFlutterMatterPackagePlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var mContext : Context
  private val scope = CoroutineScope(Dispatchers.Main + Job())

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "tp_flutter_matter_package")
    mContext = flutterPluginBinding.applicationContext
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) =
    when (call.method) {
        "getPlatformVersion" -> {
          result.success("Android ${android.os.Build.VERSION.RELEASE}")
        }
        "getDiscoverDevice" -> {
          getDiscoverDevice(result)
        }
        else -> {
          result.notImplemented()
        }
    }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun getDiscoverDevice(@NonNull result: Result) {
    val deviceController = ChipClient.getDeviceController(mContext)
    deviceController.discoverCommissionableNodes()
    scope.launch {
      delay(7000)
      updateSpinner(result)
    }
  }

  private fun updateSpinner(@NonNull result: Result) {
    val deviceController = ChipClient.getDeviceController(mContext)
    val ipAddressList = ArrayList<Map<String, Any>>()
    for(i in 0..10) {
      val device = deviceController.getDiscoveredDevice(i) ?: break
      val dict = mapOf<String, Any>(
        "deviceName" to "",
        "discriminator" to device.discriminator,
        "ipAddressList" to arrayOf(device.ipAddress),
      )
      ipAddressList.add(dict)
    }
    result.success(ipAddressList)
  }
}
