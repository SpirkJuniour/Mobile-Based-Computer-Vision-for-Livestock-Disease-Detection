package com.mifugocare.app.utils;

import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.Context;
import android.net.Uri;
import android.os.Environment;
import android.provider.MediaStore;

import androidx.annotation.NonNull;
import androidx.camera.core.ImageCapture;
import androidx.camera.core.ImageCaptureException;

import java.io.File;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

public class CameraUtils {
    
    public interface ImageCaptureCallback {
        void onImageCaptured(String imagePath);
        void onError(ImageCaptureException exception);
    }
    
    public static void captureImage(Context context, ImageCapture imageCapture, ImageCaptureCallback callback) {
        String fileName = "IMG_" + new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(new Date());
        
        ContentValues contentValues = new ContentValues();
        contentValues.put(MediaStore.MediaColumns.DISPLAY_NAME, fileName);
        contentValues.put(MediaStore.MediaColumns.MIME_TYPE, "image/jpeg");
        contentValues.put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/MifugoCare");
        
        ImageCapture.OutputFileOptions outputOptions = new ImageCapture.OutputFileOptions.Builder(
                context.getContentResolver(),
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                contentValues
        ).build();
        
        imageCapture.takePicture(
                outputOptions,
                context.getMainExecutor(),
                new ImageCapture.OnImageSavedCallback() {
                    @Override
                    public void onImageSaved(@NonNull ImageCapture.OutputFileResults output) {
                        Uri savedUri = output.getSavedUri();
                        String imagePath = savedUri != null ? savedUri.toString() : "";
                        callback.onImageCaptured(imagePath);
                    }
                    
                    @Override
                    public void onError(@NonNull ImageCaptureException exception) {
                        callback.onError(exception);
                    }
                }
        );
    }
    
    public static File createImageFile(Context context) {
        String timeStamp = new SimpleDateFormat("yyyyMMdd_HHmmss", Locale.getDefault()).format(new Date());
        String fileName = "IMG_" + timeStamp + ".jpg";
        
        File storageDir = new File(context.getExternalFilesDir(Environment.DIRECTORY_PICTURES), "MifugoCare");
        if (!storageDir.exists()) {
            storageDir.mkdirs();
        }
        
        return new File(storageDir, fileName);
    }
    
    public static String getImagePathFromUri(Context context, Uri uri) {
        String result = null;
        ContentResolver contentResolver = context.getContentResolver();
        
        try {
            java.io.InputStream inputStream = contentResolver.openInputStream(uri);
            if (inputStream != null) {
                inputStream.close();
                result = uri.toString();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        
        return result;
    }
    
    public static boolean isExternalStorageAvailable() {
        String state = Environment.getExternalStorageState();
        return Environment.MEDIA_MOUNTED.equals(state);
    }
    
    public static long getAvailableStorageSpace() {
        if (isExternalStorageAvailable()) {
            File externalDir = Environment.getExternalStorageDirectory();
            return externalDir.getFreeSpace();
        }
        return 0;
    }
    
    public static boolean hasEnoughStorageSpace(long requiredSpace) {
        return getAvailableStorageSpace() > requiredSpace;
    }
}
