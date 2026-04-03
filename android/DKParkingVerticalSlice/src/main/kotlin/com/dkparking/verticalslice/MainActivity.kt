// MainActivity.kt
// DK Parking Engine — Android Vertical Slice
// ARCore session management + Compose UI host
// Equivalent of iOS VerticalSliceApp.swift + ARKit integration

package com.dkparking.verticalslice

import android.Manifest
import android.content.pm.PackageManager
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.core.content.ContextCompat
import com.dkparking.verticalslice.ui.VerticalSliceScreen
import com.google.ar.core.ArCoreApk
import com.google.ar.core.Frame
import com.google.ar.core.Plane
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import com.google.ar.core.exceptions.CameraNotAvailableException
import com.google.ar.core.exceptions.UnavailableArcoreNotInstalledException
import com.google.ar.core.exceptions.UnavailableDeviceNotCompatibleException

class MainActivity : ComponentActivity() {

    private val viewModel: VerticalSliceViewModel by viewModels()
    private var arSession: Session? = null
    private var arResumed = false

    private val cameraPermissionLauncher = registerForActivityResult(
        ActivityResultContracts.RequestPermission()
    ) { granted ->
        if (granted) {
            initArSession()
        } else {
            Toast.makeText(this, "Camera permission required for AR evaluation.", Toast.LENGTH_LONG).show()
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        setContent {
            MaterialTheme {
                Surface(modifier = Modifier.fillMaxSize()) {
                    VerticalSliceScreen(
                        viewModel = viewModel,
                        onEvaluateRequested = { onEvaluateRequested() }
                    )
                }
            }
        }

        requestCameraPermissionIfNeeded()
    }

    override fun onResume() {
        super.onResume()
        val session = arSession ?: return
        if (!arResumed) {
            try {
                session.resume()
                arResumed = true
            } catch (e: CameraNotAvailableException) {
                Toast.makeText(this, "Camera not available for AR.", Toast.LENGTH_SHORT).show()
            }
        }
    }

    override fun onPause() {
        super.onPause()
        if (arResumed) {
            arSession?.pause()
            arResumed = false
        }
    }

    override fun onDestroy() {
        arSession?.close()
        arSession = null
        viewModel.teardown()
        super.onDestroy()
    }

    // MARK: - ARCore session management

    private fun requestCameraPermissionIfNeeded() {
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)
            == PackageManager.PERMISSION_GRANTED
        ) {
            initArSession()
        } else {
            cameraPermissionLauncher.launch(Manifest.permission.CAMERA)
        }
    }

    private fun initArSession() {
        val availability = ArCoreApk.getInstance().checkAvailability(this)
        if (availability.isUnsupported) {
            Toast.makeText(this, "ARCore is not supported on this device.", Toast.LENGTH_LONG).show()
            return
        }

        try {
            val session = Session(this)
            val config = com.google.ar.core.Config(session)
            config.planeFindingMode = com.google.ar.core.Config.PlaneFindingMode.HORIZONTAL
            session.configure(config)
            this.arSession = session
            viewModel.initializeEngine()
        } catch (e: UnavailableArcoreNotInstalledException) {
            Toast.makeText(this, "ARCore not installed. Please install ARCore.", Toast.LENGTH_LONG).show()
        } catch (e: UnavailableDeviceNotCompatibleException) {
            Toast.makeText(this, "Device not compatible with ARCore.", Toast.LENGTH_LONG).show()
        } catch (e: Exception) {
            Toast.makeText(this, "AR initialisation failed: ${e.localizedMessage}", Toast.LENGTH_LONG).show()
        }
    }

    // MARK: - AR frame polling
    // In a full implementation, attach an ArSceneView or SurfaceView and poll frames.
    // For the vertical slice, we deliver a frame to the ViewModel on each camera update.

    fun onArFrameAvailable(frame: Frame) {
        val planes = arSession
            ?.getAllTrackables(Plane::class.java)
            ?.filter { it.trackingState == TrackingState.TRACKING }
            ?: emptyList()
        viewModel.onArFrame(frame, planes)
    }

    // MARK: - Evaluate

    private fun onEvaluateRequested() {
        val session = arSession ?: return
        try {
            val frame = session.update()
            viewModel.evaluate(frame)
        } catch (e: CameraNotAvailableException) {
            Toast.makeText(this, "Camera not available for evaluation.", Toast.LENGTH_SHORT).show()
        }
    }

    fun teardown() {
        viewModel.teardown()
    }
}
