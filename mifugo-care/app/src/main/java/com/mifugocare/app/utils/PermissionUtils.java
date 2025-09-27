package com.mifugocare.app.utils;

import android.Manifest;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class PermissionUtils {
    
    public static final int CAMERA_PERMISSION_REQUEST_CODE = 1001;
    public static final int STORAGE_PERMISSION_REQUEST_CODE = 1002;
    public static final int LOCATION_PERMISSION_REQUEST_CODE = 1003;
    
    /**
     * Check if camera permission is granted
     */
    public static boolean checkCameraPermission(Context context) {
        return ContextCompat.checkSelfPermission(context, Manifest.permission.CAMERA) == PackageManager.PERMISSION_GRANTED;
    }
    
    /**
     * Check if storage permission is granted
     */
    public static boolean checkStoragePermission(Context context) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            // Android 13+ uses different permissions
            return ContextCompat.checkSelfPermission(context, Manifest.permission.READ_MEDIA_IMAGES) == PackageManager.PERMISSION_GRANTED;
        } else {
            return ContextCompat.checkSelfPermission(context, Manifest.permission.READ_EXTERNAL_STORAGE) == PackageManager.PERMISSION_GRANTED;
        }
    }
    
    /**
     * Check if location permission is granted
     */
    public static boolean checkLocationPermission(Context context) {
        return ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED ||
               ContextCompat.checkSelfPermission(context, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED;
    }
    
    /**
     * Request camera permission
     */
    public static void requestCameraPermission(Activity activity, int requestCode) {
        if (ActivityCompat.shouldShowRequestPermissionRationale(activity, Manifest.permission.CAMERA)) {
            // Show explanation if needed
            showPermissionExplanation(activity, "Camera permission is needed to take photos for disease diagnosis.");
        }
        ActivityCompat.requestPermissions(activity, new String[]{Manifest.permission.CAMERA}, requestCode);
    }
    
    /**
     * Request storage permission
     */
    public static void requestStoragePermission(Activity activity, int requestCode) {
        String[] permissions;
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            permissions = new String[]{Manifest.permission.READ_MEDIA_IMAGES};
        } else {
            permissions = new String[]{Manifest.permission.READ_EXTERNAL_STORAGE};
        }
        
        if (ActivityCompat.shouldShowRequestPermissionRationale(activity, permissions[0])) {
            showPermissionExplanation(activity, "Storage permission is needed to access and save images.");
        }
        ActivityCompat.requestPermissions(activity, permissions, requestCode);
    }
    
    /**
     * Request location permission
     */
    public static void requestLocationPermission(Activity activity, int requestCode) {
        if (ActivityCompat.shouldShowRequestPermissionRationale(activity, Manifest.permission.ACCESS_FINE_LOCATION)) {
            showPermissionExplanation(activity, "Location permission is needed to record the location of livestock diagnoses.");
        }
        ActivityCompat.requestPermissions(activity, 
            new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION}, 
            requestCode);
    }
    
    /**
     * Check if all required permissions are granted
     */
    public static boolean hasAllRequiredPermissions(Context context) {
        return checkCameraPermission(context) && checkStoragePermission(context);
    }
    
    /**
     * Request all required permissions
     */
    public static void requestAllRequiredPermissions(Activity activity) {
        if (!hasAllRequiredPermissions(activity)) {
            String[] permissions = new String[]{Manifest.permission.CAMERA};
            
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                permissions = new String[]{Manifest.permission.CAMERA, Manifest.permission.READ_MEDIA_IMAGES};
            } else {
                permissions = new String[]{Manifest.permission.CAMERA, Manifest.permission.READ_EXTERNAL_STORAGE};
            }
            
            ActivityCompat.requestPermissions(activity, permissions, CAMERA_PERMISSION_REQUEST_CODE);
        }
    }
    
    /**
     * Check if permission was granted
     */
    public static boolean isPermissionGranted(int[] grantResults) {
        return grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED;
    }
    
    /**
     * Check if multiple permissions were granted
     */
    public static boolean arePermissionsGranted(int[] grantResults) {
        for (int result : grantResults) {
            if (result != PackageManager.PERMISSION_GRANTED) {
                return false;
            }
        }
        return grantResults.length > 0;
    }
    
    /**
     * Show permission explanation dialog
     */
    private static void showPermissionExplanation(Activity activity, String message) {
        // You can implement a custom dialog here
        // For now, we'll just show a toast
        android.widget.Toast.makeText(activity, message, android.widget.Toast.LENGTH_LONG).show();
    }
    
    /**
     * Check if we should show request permission rationale
     */
    public static boolean shouldShowRequestPermissionRationale(Activity activity, String permission) {
        return ActivityCompat.shouldShowRequestPermissionRationale(activity, permission);
    }
    
    /**
     * Get permission status message
     */
    public static String getPermissionStatusMessage(Context context) {
        StringBuilder message = new StringBuilder();
        
        if (!checkCameraPermission(context)) {
            message.append("Camera permission is required for taking photos.\n");
        }
        
        if (!checkStoragePermission(context)) {
            message.append("Storage permission is required for saving images.\n");
        }
        
        if (!checkLocationPermission(context)) {
            message.append("Location permission is optional but recommended.\n");
        }
        
        return message.toString();
    }
}
