package com.mifugocare.app.activities;

import android.Manifest;
import android.content.pm.PackageManager;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.camera.core.Camera;
import androidx.camera.core.CameraSelector;
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;
import androidx.camera.core.Preview;
import androidx.camera.lifecycle.ProcessCameraProvider;
import androidx.camera.view.PreviewView;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import com.google.common.util.concurrent.ListenableFuture;
import com.mifugocare.app.R;
import com.mifugocare.app.utils.CameraUtils;
import com.mifugocare.app.utils.PermissionUtils;

import java.util.concurrent.ExecutionException;

public class CameraActivity extends AppCompatActivity {
    
    private static final int CAMERA_PERMISSION_REQUEST_CODE = 1001;
    
    private PreviewView previewView;
    private Button btnCapture, btnSwitchCamera;
    private ImageCapture imageCapture;
    private Camera camera;
    private boolean isBackCamera = true;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_camera);
        
        initializeViews();
        setupClickListeners();
        
        if (PermissionUtils.checkCameraPermission(this)) {
            startCamera();
        } else {
            PermissionUtils.requestCameraPermission(this, CAMERA_PERMISSION_REQUEST_CODE);
        }
    }
    
    private void initializeViews() {
        previewView = findViewById(R.id.preview_view);
        btnCapture = findViewById(R.id.btn_capture);
        btnSwitchCamera = findViewById(R.id.btn_switch_camera);
    }
    
    private void setupClickListeners() {
        btnCapture.setOnClickListener(v -> captureImage());
        btnSwitchCamera.setOnClickListener(v -> switchCamera());
    }
    
    private void startCamera() {
        ListenableFuture<ProcessCameraProvider> cameraProviderFuture = 
            ProcessCameraProvider.getInstance(this);
        
        cameraProviderFuture.addListener(() -> {
            try {
                ProcessCameraProvider cameraProvider = cameraProviderFuture.get();
                bindCamera(cameraProvider);
            } catch (ExecutionException | InterruptedException e) {
                e.printStackTrace();
            }
        }, ContextCompat.getMainExecutor(this));
    }
    
    private void bindCamera(ProcessCameraProvider cameraProvider) {
        Preview preview = new Preview.Builder().build();
        preview.setSurfaceProvider(previewView.getSurfaceProvider());
        
        imageCapture = new ImageCapture.Builder()
            .setCaptureMode(ImageCapture.CAPTURE_MODE_MINIMIZE_LATENCY)
            .build();
        
        CameraSelector cameraSelector = isBackCamera ? 
            CameraSelector.DEFAULT_BACK_CAMERA : 
            CameraSelector.DEFAULT_FRONT_CAMERA;
        
        try {
            cameraProvider.unbindAll();
            camera = cameraProvider.bindToLifecycle(
                this, cameraSelector, preview, imageCapture);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
    
    private void captureImage() {
        if (imageCapture == null) return;
        
        CameraUtils.captureImage(this, imageCapture, new CameraUtils.ImageCaptureCallback() {
            @Override
            public void onImageCaptured(String imagePath) {
                // Process captured image for disease diagnosis
                Toast.makeText(CameraActivity.this, "Picha imepigwa: " + imagePath, Toast.LENGTH_SHORT).show();
                finish();
            }
            
            @Override
            public void onError(ImageCaptureException exception) {
                Toast.makeText(CameraActivity.this, "Imeshindwa kupiga picha", Toast.LENGTH_SHORT).show();
            }
        });
    }
    
    private void switchCamera() {
        isBackCamera = !isBackCamera;
        startCamera();
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == CAMERA_PERMISSION_REQUEST_CODE) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                startCamera();
            } else {
                Toast.makeText(this, "Ruhusa ya kamera inahitajika", Toast.LENGTH_SHORT).show();
                finish();
            }
        }
    }
}
