// VerticalSliceScreen.kt
// DK Parking Engine — Android Vertical Slice UI
// Jetpack Compose equivalent of iOS VerticalSliceRootView.swift
// Locked vocabulary per user_disclosures_and_copy.md

package com.dkparking.verticalslice.ui

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.dkparking.sdk.ar.ARSessionQuality
import com.dkparking.sdk.core.DecisionState
import com.dkparking.verticalslice.EvaluationUiState
import com.dkparking.verticalslice.VerticalSliceViewModel

// MARK: - Decision state colors (locked per user_disclosures_and_copy.md §2)

private fun stateColor(state: DecisionState): Color = when (state) {
    DecisionState.LEGAL_WITH_BUFFER -> Color(0xFF2E7D32)
    DecisionState.PROBABLY_LEGAL    -> Color(0xFF558B2F)
    DecisionState.PROBABLY_ILLEGAL  -> Color(0xFFE65100)
    DecisionState.ILLEGAL           -> Color(0xFFC62828)
    DecisionState.UNVERIFIABLE      -> Color(0xFF37474F)
}

// MARK: - Root screen

@Composable
fun VerticalSliceScreen(
    viewModel: VerticalSliceViewModel,
    onEvaluateRequested: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val sessionQuality by viewModel.sessionQuality.collectAsState()

    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(Color(0xFF121212))
            .padding(16.dp)
            .verticalScroll(rememberScrollState()),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Spacer(modifier = Modifier.height(16.dp))

        // Title
        Text(
            text = "DK Parking",
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White
        )
        Text(
            text = "Android Vertical Slice — pedestrian_crossing_5m",
            fontSize = 13.sp,
            color = Color(0xFF9E9E9E),
            textAlign = TextAlign.Center
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Session quality banner
        SessionQualityBanner(quality = sessionQuality, uiState = uiState)

        Spacer(modifier = Modifier.height(16.dp))

        // AR preview placeholder (ARCore SceneView is attached in MainActivity)
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .height(220.dp)
                .background(Color(0xFF1E1E1E), RoundedCornerShape(12.dp)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "ARCore preview\n(attached in MainActivity)",
                color = Color(0xFF616161),
                textAlign = TextAlign.Center,
                fontSize = 13.sp
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Evaluate button
        val isReady = uiState is EvaluationUiState.ReadyToEvaluate
        Button(
            onClick = onEvaluateRequested,
            enabled = isReady,
            modifier = Modifier
                .fillMaxWidth()
                .height(52.dp),
            shape = RoundedCornerShape(10.dp),
            colors = ButtonDefaults.buttonColors(
                containerColor = Color(0xFF1565C0),
                disabledContainerColor = Color(0xFF263238)
            )
        ) {
            Text(
                text = if (isReady) "Evaluate" else "Waiting for AR…",
                fontSize = 16.sp,
                fontWeight = FontWeight.SemiBold,
                color = Color.White
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // Result card
        when (val state = uiState) {
            is EvaluationUiState.Result -> ResultCard(
                state = state,
                onRetry = { viewModel.reset() }
            )
            is EvaluationUiState.InitFailed -> ErrorCard(message = state.message)
            else -> {}
        }

        Spacer(modifier = Modifier.height(24.dp))

        // Universal limitations notice (locked per user_disclosures_and_copy.md §6)
        Text(
            text = "This app evaluates only specific supported Danish stopping and parking rules. " +
                   "Other rules, signs, and restrictions may apply. This is not legal advice.",
            fontSize = 11.sp,
            color = Color(0xFF757575),
            textAlign = TextAlign.Center,
            fontStyle = FontStyle.Italic,
            modifier = Modifier.padding(horizontal = 8.dp)
        )

        Spacer(modifier = Modifier.height(16.dp))
    }
}

// MARK: - Session quality banner

@Composable
private fun SessionQualityBanner(quality: ARSessionQuality, uiState: EvaluationUiState) {
    val (text, color) = when {
        uiState is EvaluationUiState.Idle || uiState is EvaluationUiState.Initializing ->
            Pair("Initialising…", Color(0xFF616161))
        uiState is EvaluationUiState.InitFailed ->
            Pair("Initialisation failed", Color(0xFFC62828))
        !quality.isValid && quality.metricScaleScore < 0.3 ->
            Pair("Move slowly to build AR tracking", Color(0xFFE65100))
        !quality.isValid && quality.planeStabilityScore < 0.5 ->
            Pair("Point camera at road surface to detect ground plane", Color(0xFFE65100))
        !quality.isValid ->
            Pair("Improving AR quality…", Color(0xFFFF8F00))
        quality.isValid ->
            Pair("AR ready — tap Evaluate", Color(0xFF2E7D32))
        else ->
            Pair("Checking AR session…", Color(0xFF616161))
    }
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .height(40.dp),
        shape = RoundedCornerShape(8.dp),
        color = color.copy(alpha = 0.15f),
        tonalElevation = 0.dp
    ) {
        Box(contentAlignment = Alignment.Center) {
            Text(text = text, color = color, fontSize = 13.sp, fontWeight = FontWeight.Medium)
        }
    }
}

// MARK: - Result card

@Composable
private fun ResultCard(
    state: EvaluationUiState.Result,
    onRetry: () -> Unit
) {
    val cardColor = stateColor(state.decisionState)

    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        color = cardColor.copy(alpha = 0.12f),
        tonalElevation = 0.dp
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            horizontalAlignment = Alignment.Start
        ) {
            // Decision label
            Text(
                text = state.displayLabel,
                fontSize = 22.sp,
                fontWeight = FontWeight.Bold,
                color = cardColor
            )

            Spacer(modifier = Modifier.height(8.dp))

            // Explanation body
            Text(
                text = state.explanationBody,
                fontSize = 14.sp,
                color = Color(0xFFE0E0E0)
            )

            // Refusal explanation (UNVERIFIABLE only)
            if (state.refusalExplanation != null) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = state.refusalExplanation,
                    fontSize = 13.sp,
                    color = Color(0xFFBDBDBD)
                )
            }

            // Retry guidance (UNVERIFIABLE only)
            if (state.retryGuidance != null) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = state.retryGuidance,
                    fontSize = 13.sp,
                    color = Color(0xFF80DEEA),
                    fontStyle = FontStyle.Italic
                )
            }

            // Measurement summary
            if (state.measurementSummary != null) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = state.measurementSummary,
                    fontSize = 12.sp,
                    color = Color(0xFF9E9E9E)
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            // Per-family disclosure (locked per user_disclosures_and_copy.md §7)
            Text(
                text = state.familyDisclosure,
                fontSize = 11.sp,
                color = Color(0xFF757575),
                fontStyle = FontStyle.Italic
            )

            Spacer(modifier = Modifier.height(12.dp))

            // Retry button
            OutlinedButton(
                onClick = onRetry,
                modifier = Modifier.fillMaxWidth(),
                shape = RoundedCornerShape(8.dp),
                colors = ButtonDefaults.outlinedButtonColors(contentColor = cardColor)
            ) {
                Text(text = "Evaluate again", fontSize = 14.sp)
            }
        }
    }
}

// MARK: - Error card

@Composable
private fun ErrorCard(message: String) {
    Surface(
        modifier = Modifier.fillMaxWidth(),
        shape = RoundedCornerShape(12.dp),
        color = Color(0xFF37474F).copy(alpha = 0.2f)
    ) {
        Text(
            text = message,
            modifier = Modifier.padding(16.dp),
            color = Color(0xFFEF9A9A),
            fontSize = 13.sp
        )
    }
}
