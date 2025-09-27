package com.mifugocare.app.activities;

import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;

import androidx.appcompat.app.AppCompatActivity;

import com.mifugocare.app.R;
import com.mifugocare.app.utils.SharedPreferencesManager;

public class SplashActivity extends AppCompatActivity {
    
    private static final int SPLASH_DELAY = 3000; // 3 seconds
    private SharedPreferencesManager prefsManager;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_splash);
        
        prefsManager = new SharedPreferencesManager(this);
        
        // Check if this is the first launch
        if (prefsManager.isFirstLaunch()) {
            // Show onboarding after splash
            navigateToOnboarding();
        } else {
            // Go directly to main activity
            navigateToMain();
        }
    }
    
    private void navigateToOnboarding() {
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            Intent intent = new Intent(SplashActivity.this, OnboardingActivity.class);
            startActivity(intent);
            finish();
        }, SPLASH_DELAY);
    }
    
    private void navigateToMain() {
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            Intent intent = new Intent(SplashActivity.this, MainActivity.class);
            startActivity(intent);
            finish();
        }, SPLASH_DELAY);
    }
    
    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Clean up any pending handlers
    }
}
