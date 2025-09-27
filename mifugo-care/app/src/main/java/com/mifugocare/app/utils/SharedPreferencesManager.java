package com.mifugocare.app.utils;

import android.content.Context;
import android.content.SharedPreferences;

public class SharedPreferencesManager {
    
    private static final String PREF_NAME = "mifugo_care_prefs";
    private static final String KEY_NOTIFICATIONS_ENABLED = "notifications_enabled";
    private static final String KEY_AUTO_DIAGNOSIS_ENABLED = "auto_diagnosis_enabled";
    private static final String KEY_DATA_SHARING_ENABLED = "data_sharing_enabled";
    private static final String KEY_FIRST_LAUNCH = "first_launch";
    private static final String KEY_USER_LANGUAGE = "user_language";
    private static final String KEY_CAMERA_QUALITY = "camera_quality";
    private static final String KEY_DIAGNOSIS_CONFIDENCE_THRESHOLD = "diagnosis_confidence_threshold";
    private static final String KEY_FARMER_ID = "farmer_id";
    private static final String KEY_LAST_SYNC_TIME = "last_sync_time";
    
    private SharedPreferences preferences;
    
    public SharedPreferencesManager(Context context) {
        preferences = context.getSharedPreferences(PREF_NAME, Context.MODE_PRIVATE);
    }
    
    // Notification settings
    public boolean isNotificationsEnabled() {
        return preferences.getBoolean(KEY_NOTIFICATIONS_ENABLED, true);
    }
    
    public void setNotificationsEnabled(boolean enabled) {
        preferences.edit().putBoolean(KEY_NOTIFICATIONS_ENABLED, enabled).apply();
    }
    
    // Auto diagnosis settings
    public boolean isAutoDiagnosisEnabled() {
        return preferences.getBoolean(KEY_AUTO_DIAGNOSIS_ENABLED, false);
    }
    
    public void setAutoDiagnosisEnabled(boolean enabled) {
        preferences.edit().putBoolean(KEY_AUTO_DIAGNOSIS_ENABLED, enabled).apply();
    }
    
    // Data sharing settings
    public boolean isDataSharingEnabled() {
        return preferences.getBoolean(KEY_DATA_SHARING_ENABLED, false);
    }
    
    public void setDataSharingEnabled(boolean enabled) {
        preferences.edit().putBoolean(KEY_DATA_SHARING_ENABLED, enabled).apply();
    }
    
    // First launch
    public boolean isFirstLaunch() {
        return preferences.getBoolean(KEY_FIRST_LAUNCH, true);
    }
    
    public void setFirstLaunch(boolean isFirstLaunch) {
        preferences.edit().putBoolean(KEY_FIRST_LAUNCH, isFirstLaunch).apply();
    }
    
    // User language preference
    public String getUserLanguage() {
        return preferences.getString(KEY_USER_LANGUAGE, "en");
    }
    
    public void setUserLanguage(String language) {
        preferences.edit().putString(KEY_USER_LANGUAGE, language).apply();
    }
    
    // Camera quality setting
    public String getCameraQuality() {
        return preferences.getString(KEY_CAMERA_QUALITY, "high");
    }
    
    public void setCameraQuality(String quality) {
        preferences.edit().putString(KEY_CAMERA_QUALITY, quality).apply();
    }
    
    // Diagnosis confidence threshold
    public float getDiagnosisConfidenceThreshold() {
        return preferences.getFloat(KEY_DIAGNOSIS_CONFIDENCE_THRESHOLD, 0.7f);
    }
    
    public void setDiagnosisConfidenceThreshold(float threshold) {
        preferences.edit().putFloat(KEY_DIAGNOSIS_CONFIDENCE_THRESHOLD, threshold).apply();
    }
    
    // Current farmer ID
    public int getCurrentFarmerId() {
        return preferences.getInt(KEY_FARMER_ID, 1); // Default to 1 for demo
    }
    
    public void setCurrentFarmerId(int farmerId) {
        preferences.edit().putInt(KEY_FARMER_ID, farmerId).apply();
    }
    
    // Last sync time
    public long getLastSyncTime() {
        return preferences.getLong(KEY_LAST_SYNC_TIME, 0);
    }
    
    public void setLastSyncTime(long timestamp) {
        preferences.edit().putLong(KEY_LAST_SYNC_TIME, timestamp).apply();
    }
    
    // Clear all preferences
    public void clearAll() {
        preferences.edit().clear().apply();
    }
    
    // Reset to default values
    public void resetToDefaults() {
        SharedPreferences.Editor editor = preferences.edit();
        editor.putBoolean(KEY_NOTIFICATIONS_ENABLED, true);
        editor.putBoolean(KEY_AUTO_DIAGNOSIS_ENABLED, false);
        editor.putBoolean(KEY_DATA_SHARING_ENABLED, false);
        editor.putString(KEY_USER_LANGUAGE, "en");
        editor.putString(KEY_CAMERA_QUALITY, "high");
        editor.putFloat(KEY_DIAGNOSIS_CONFIDENCE_THRESHOLD, 0.7f);
        editor.putInt(KEY_FARMER_ID, 1);
        editor.apply();
    }
    
    // Check if specific setting exists
    public boolean hasSetting(String key) {
        return preferences.contains(key);
    }
    
    // Get all preferences as a string for debugging
    public String getAllPreferences() {
        return preferences.getAll().toString();
    }
}
