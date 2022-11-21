package com.tp.flutter.matter.plugin.tp_flutter_matter_package

import android.content.Context
import android.util.Log
import chip.devicecontroller.ChipDeviceController
import chip.devicecontroller.ControllerParams
import chip.devicecontroller.GetConnectedDeviceCallbackJni
import chip.platform.*
import kotlin.coroutines.resume
import kotlin.coroutines.resumeWithException
import kotlin.coroutines.suspendCoroutine

object ChipClient {
    private const val TAG = "ChipClient"
    private lateinit var chipDeviceController: ChipDeviceController
    private lateinit var androidPlatform: AndroidChipPlatform
    /* 0xFFF4 is a test vendor ID, replace with your assigned company ID */
    private const val VENDOR_ID = 0xFFF4

    fun getDeviceController(context: Context): ChipDeviceController {
        getAndroidChipPlatform(context)

        if (!this::chipDeviceController.isInitialized) {
            chipDeviceController = ChipDeviceController(ControllerParams.newBuilder().setControllerVendorId(VENDOR_ID).build())
        }
        return chipDeviceController
    }

    fun getAndroidChipPlatform(context: Context?): AndroidChipPlatform {
        if (!this::androidPlatform.isInitialized && context != null) {
            //force ChipDeviceController load jni
            ChipDeviceController.loadJni()
            androidPlatform = AndroidChipPlatform(AndroidBleManager(), PreferencesKeyValueStoreManager(context), PreferencesConfigurationManager(context), NsdManagerServiceResolver(context), NsdManagerServiceBrowser(context), ChipMdnsCallbackImpl(), DiagnosticDataProviderImpl(context))
        }
        return androidPlatform
    }

    /**
     * Wrapper around [ChipDeviceController.getConnectedDevicePointer] to return the value directly.
     */
    suspend fun getConnectedDevicePointer(context: Context, nodeId: Long): Long {
        // TODO (#21539) This is a memory leak because we currently never call releaseConnectedDevicePointer
        // once we are done with the returned device pointer. Memory leak was introduced since the refactor
        // that introduced it was very large in order to fix a use after free, which was considered to be
        // worse than the memory leak that was introduced.
        return suspendCoroutine { continuation ->
            getDeviceController(context).getConnectedDevicePointer(
                nodeId,
                object : GetConnectedDeviceCallbackJni.GetConnectedDeviceCallback {
                    override fun onDeviceConnected(devicePointer: Long) {
                        Log.d(TAG, "Got connected device pointer")
                        continuation.resume(devicePointer)
                    }

                    override fun onConnectionFailure(nodeId: Long, error: Exception) {
                        val errorMessage = "Unable to get connected device with nodeId $nodeId"
                        Log.e(TAG, errorMessage, error)
                        continuation.resumeWithException(IllegalStateException(errorMessage))
                    }
                })
        }
    }
}
