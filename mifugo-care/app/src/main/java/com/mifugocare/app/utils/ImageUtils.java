package com.mifugocare.app.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;

import java.io.IOException;
import java.io.InputStream;

public class ImageUtils {
    
    /**
     * Load bitmap from URI with proper orientation
     */
    public static Bitmap loadBitmapFromUri(Context context, Uri uri) {
        try {
            InputStream inputStream = context.getContentResolver().openInputStream(uri);
            Bitmap bitmap = BitmapFactory.decodeStream(inputStream);
            inputStream.close();
            
            // Apply EXIF orientation
            int orientation = getExifOrientation(context, uri);
            return rotateBitmap(bitmap, orientation);
            
        } catch (IOException e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Load bitmap from file path
     */
    public static Bitmap loadBitmapFromPath(String imagePath) {
        try {
            Bitmap bitmap = BitmapFactory.decodeFile(imagePath);
            
            // Apply EXIF orientation
            int orientation = getExifOrientationFromPath(imagePath);
            return rotateBitmap(bitmap, orientation);
            
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Get EXIF orientation from URI
     */
    private static int getExifOrientation(Context context, Uri uri) {
        try {
            InputStream inputStream = context.getContentResolver().openInputStream(uri);
            ExifInterface exif = new ExifInterface(inputStream);
            int orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
            inputStream.close();
            return orientation;
        } catch (IOException e) {
            e.printStackTrace();
            return ExifInterface.ORIENTATION_NORMAL;
        }
    }
    
    /**
     * Get EXIF orientation from file path
     */
    private static int getExifOrientationFromPath(String imagePath) {
        try {
            ExifInterface exif = new ExifInterface(imagePath);
            return exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL);
        } catch (IOException e) {
            e.printStackTrace();
            return ExifInterface.ORIENTATION_NORMAL;
        }
    }
    
    /**
     * Rotate bitmap based on EXIF orientation
     */
    private static Bitmap rotateBitmap(Bitmap bitmap, int orientation) {
        if (bitmap == null || orientation == ExifInterface.ORIENTATION_NORMAL) {
            return bitmap;
        }
        
        Matrix matrix = new Matrix();
        
        switch (orientation) {
            case ExifInterface.ORIENTATION_ROTATE_90:
                matrix.postRotate(90);
                break;
            case ExifInterface.ORIENTATION_ROTATE_180:
                matrix.postRotate(180);
                break;
            case ExifInterface.ORIENTATION_ROTATE_270:
                matrix.postRotate(270);
                break;
            case ExifInterface.ORIENTATION_FLIP_HORIZONTAL:
                matrix.postScale(-1, 1);
                break;
            case ExifInterface.ORIENTATION_FLIP_VERTICAL:
                matrix.postScale(1, -1);
                break;
            case ExifInterface.ORIENTATION_TRANSPOSE:
                matrix.postRotate(90);
                matrix.postScale(-1, 1);
                break;
            case ExifInterface.ORIENTATION_TRANSVERSE:
                matrix.postRotate(270);
                matrix.postScale(-1, 1);
                break;
            default:
                return bitmap;
        }
        
        try {
            Bitmap rotatedBitmap = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
            if (rotatedBitmap != bitmap) {
                bitmap.recycle();
            }
            return rotatedBitmap;
        } catch (OutOfMemoryError e) {
            e.printStackTrace();
            return bitmap;
        }
    }
    
    /**
     * Compress bitmap to reduce memory usage
     */
    public static Bitmap compressBitmap(Bitmap original, int maxWidth, int maxHeight) {
        if (original == null) {
            return null;
        }
        
        int width = original.getWidth();
        int height = original.getHeight();
        
        if (width <= maxWidth && height <= maxHeight) {
            return original;
        }
        
        float ratio = Math.min((float) maxWidth / width, (float) maxHeight / height);
        int newWidth = Math.round(width * ratio);
        int newHeight = Math.round(height * ratio);
        
        return Bitmap.createScaledBitmap(original, newWidth, newHeight, true);
    }
    
    /**
     * Convert bitmap to byte array
     */
    public static byte[] bitmapToByteArray(Bitmap bitmap, int quality) {
        java.io.ByteArrayOutputStream stream = new java.io.ByteArrayOutputStream();
        bitmap.compress(Bitmap.CompressFormat.JPEG, quality, stream);
        return stream.toByteArray();
    }
    
    /**
     * Create bitmap from byte array
     */
    public static Bitmap byteArrayToBitmap(byte[] byteArray) {
        return BitmapFactory.decodeByteArray(byteArray, 0, byteArray.length);
    }
    
    /**
     * Calculate image file size in bytes
     */
    public static long calculateImageSize(Bitmap bitmap, int quality) {
        byte[] byteArray = bitmapToByteArray(bitmap, quality);
        return byteArray.length;
    }
    
    /**
     * Check if image is landscape or portrait
     */
    public static boolean isLandscape(Bitmap bitmap) {
        return bitmap != null && bitmap.getWidth() > bitmap.getHeight();
    }
    
    /**
     * Crop bitmap to square aspect ratio
     */
    public static Bitmap cropToSquare(Bitmap bitmap) {
        if (bitmap == null) {
            return null;
        }
        
        int size = Math.min(bitmap.getWidth(), bitmap.getHeight());
        int x = (bitmap.getWidth() - size) / 2;
        int y = (bitmap.getHeight() - size) / 2;
        
        return Bitmap.createBitmap(bitmap, x, y, size, size);
    }
    
    /**
     * Apply basic image enhancement
     */
    public static Bitmap enhanceImage(Bitmap bitmap) {
        if (bitmap == null) {
            return null;
        }
        
        // Simple brightness adjustment
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        Bitmap enhanced = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        
        int[] pixels = new int[width * height];
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
        
        for (int i = 0; i < pixels.length; i++) {
            int pixel = pixels[i];
            int a = (pixel >> 24) & 0xFF;
            int r = (pixel >> 16) & 0xFF;
            int g = (pixel >> 8) & 0xFF;
            int b = pixel & 0xFF;
            
            // Increase brightness slightly
            r = Math.min(255, (int) (r * 1.1));
            g = Math.min(255, (int) (g * 1.1));
            b = Math.min(255, (int) (b * 1.1));
            
            pixels[i] = (a << 24) | (r << 16) | (g << 8) | b;
        }
        
        enhanced.setPixels(pixels, 0, width, 0, 0, width, height);
        return enhanced;
    }
}
