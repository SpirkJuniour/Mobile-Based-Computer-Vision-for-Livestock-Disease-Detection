package com.mifugocare.app.models;

import android.graphics.Bitmap;
import android.graphics.Matrix;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;

public class ImageProcessor {
    
    private static final int MODEL_INPUT_SIZE = 224;
    private static final float MEAN = 127.5f;
    private static final float STD = 127.5f;
    
    /**
     * Resize bitmap to model input size while maintaining aspect ratio
     */
    public static Bitmap resizeBitmap(Bitmap bitmap) {
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        
        float scaleWidth = (float) MODEL_INPUT_SIZE / width;
        float scaleHeight = (float) MODEL_INPUT_SIZE / height;
        float scale = Math.min(scaleWidth, scaleHeight);
        
        Matrix matrix = new Matrix();
        matrix.postScale(scale, scale);
        
        return Bitmap.createBitmap(bitmap, 0, 0, width, height, matrix, true);
    }
    
    /**
     * Crop bitmap to square and resize to model input size
     */
    public static Bitmap cropAndResize(Bitmap bitmap) {
        int size = Math.min(bitmap.getWidth(), bitmap.getHeight());
        int x = (bitmap.getWidth() - size) / 2;
        int y = (bitmap.getHeight() - size) / 2;
        
        Bitmap cropped = Bitmap.createBitmap(bitmap, x, y, size, size);
        Bitmap resized = Bitmap.createScaledBitmap(cropped, MODEL_INPUT_SIZE, MODEL_INPUT_SIZE, true);
        
        if (cropped != bitmap) {
            cropped.recycle();
        }
        
        return resized;
    }
    
    /**
     * Convert bitmap to ByteBuffer for TensorFlow Lite
     */
    public static ByteBuffer bitmapToByteBuffer(Bitmap bitmap) {
        ByteBuffer byteBuffer = ByteBuffer.allocateDirect(4 * MODEL_INPUT_SIZE * MODEL_INPUT_SIZE * 3);
        byteBuffer.order(ByteOrder.nativeOrder());
        
        int[] pixels = new int[MODEL_INPUT_SIZE * MODEL_INPUT_SIZE];
        bitmap.getPixels(pixels, 0, MODEL_INPUT_SIZE, 0, 0, MODEL_INPUT_SIZE, MODEL_INPUT_SIZE);
        
        for (int pixel : pixels) {
            // Extract RGB values
            int r = (pixel >> 16) & 0xFF;
            int g = (pixel >> 8) & 0xFF;
            int b = pixel & 0xFF;
            
            // Normalize to [-1, 1] range
            float rf = (r - MEAN) / STD;
            float gf = (g - MEAN) / STD;
            float bf = (b - MEAN) / STD;
            
            byteBuffer.putFloat(rf);
            byteBuffer.putFloat(gf);
            byteBuffer.putFloat(bf);
        }
        
        return byteBuffer;
    }
    
    /**
     * Rotate bitmap based on EXIF orientation
     */
    public static Bitmap rotateBitmap(Bitmap bitmap, int orientation) {
        Matrix matrix = new Matrix();
        
        switch (orientation) {
            case 1: // Normal
                return bitmap;
            case 2: // Flip horizontal
                matrix.postScale(-1, 1);
                break;
            case 3: // Rotate 180
                matrix.postRotate(180);
                break;
            case 4: // Flip vertical
                matrix.postScale(1, -1);
                break;
            case 5: // Rotate 90 + Flip horizontal
                matrix.postRotate(90);
                matrix.postScale(-1, 1);
                break;
            case 6: // Rotate 90
                matrix.postRotate(90);
                break;
            case 7: // Rotate 270 + Flip horizontal
                matrix.postRotate(270);
                matrix.postScale(-1, 1);
                break;
            case 8: // Rotate 270
                matrix.postRotate(270);
                break;
            default:
                return bitmap;
        }
        
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), matrix, true);
    }
    
    /**
     * Apply image enhancement filters
     */
    public static Bitmap enhanceImage(Bitmap bitmap) {
        // Simple brightness and contrast adjustment
        // In a real implementation, you might use more sophisticated filters
        
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        Bitmap enhanced = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888);
        
        int[] pixels = new int[width * height];
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
        
        for (int i = 0; i < pixels.length; i++) {
            int pixel = pixels[i];
            int r = (pixel >> 16) & 0xFF;
            int g = (pixel >> 8) & 0xFF;
            int b = pixel & 0xFF;
            
            // Apply slight brightness increase
            r = Math.min(255, (int) (r * 1.1));
            g = Math.min(255, (int) (g * 1.1));
            b = Math.min(255, (int) (b * 1.1));
            
            pixels[i] = (pixel & 0xFF000000) | (r << 16) | (g << 8) | b;
        }
        
        enhanced.setPixels(pixels, 0, width, 0, 0, width, height);
        return enhanced;
    }
    
    /**
     * Check if image quality is suitable for diagnosis
     */
    public static boolean isImageQualityGood(Bitmap bitmap) {
        // Basic quality checks
        if (bitmap == null || bitmap.isRecycled()) {
            return false;
        }
        
        int width = bitmap.getWidth();
        int height = bitmap.getHeight();
        
        // Check minimum size
        if (width < 224 || height < 224) {
            return false;
        }
        
        // Check if image is too dark or too bright
        // This is a simplified check - in reality, you'd use more sophisticated algorithms
        int[] pixels = new int[width * height];
        bitmap.getPixels(pixels, 0, width, 0, 0, width, height);
        
        long totalBrightness = 0;
        for (int pixel : pixels) {
            int r = (pixel >> 16) & 0xFF;
            int g = (pixel >> 8) & 0xFF;
            int b = pixel & 0xFF;
            totalBrightness += (r + g + b) / 3;
        }
        
        float averageBrightness = totalBrightness / (float) pixels.length;
        
        // Acceptable brightness range (0-255 scale)
        return averageBrightness >= 30 && averageBrightness <= 225;
    }
}
