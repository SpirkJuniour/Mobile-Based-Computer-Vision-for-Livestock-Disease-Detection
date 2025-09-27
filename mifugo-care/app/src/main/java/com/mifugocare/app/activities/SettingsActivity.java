package com.mifugocare.app.activities;

import android.content.SharedPreferences;
import android.os.Bundle;
import android.widget.CompoundButton;
import android.widget.Switch;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.mifugocare.app.R;
import com.mifugocare.app.utils.SharedPreferencesManager;

public class SettingsActivity extends AppCompatActivity {
    
    private Switch switchNotifications;
    private Switch switchAutoDiagnosis;
    private Switch switchDataSharing;
    private TextView textVersion;
    private SharedPreferencesManager prefsManager;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_settings);
        
        initializeViews();
        setupPreferences();
        setupClickListeners();
        loadSettings();
    }
    
    private void initializeViews() {
        switchNotifications = findViewById(R.id.switch_notifications);
        switchAutoDiagnosis = findViewById(R.id.switch_auto_diagnosis);
        switchDataSharing = findViewById(R.id.switch_data_sharing);
        textVersion = findViewById(R.id.text_version);
        
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(getString(R.string.nav_settings));
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
    }
    
    private void setupPreferences() {
        prefsManager = new SharedPreferencesManager(this);
        textVersion.setText(getString(R.string.settings_version, "1.0.0"));
    }
    
    private void setupClickListeners() {
        switchNotifications.setOnCheckedChangeListener((buttonView, isChecked) -> {
            prefsManager.setNotificationsEnabled(isChecked);
        });
        
        switchAutoDiagnosis.setOnCheckedChangeListener((buttonView, isChecked) -> {
            prefsManager.setAutoDiagnosisEnabled(isChecked);
        });
        
        switchDataSharing.setOnCheckedChangeListener((buttonView, isChecked) -> {
            prefsManager.setDataSharingEnabled(isChecked);
        });
    }
    
    private void loadSettings() {
        switchNotifications.setChecked(prefsManager.isNotificationsEnabled());
        switchAutoDiagnosis.setChecked(prefsManager.isAutoDiagnosisEnabled());
        switchDataSharing.setChecked(prefsManager.isDataSharingEnabled());
    }
    
    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }
}
