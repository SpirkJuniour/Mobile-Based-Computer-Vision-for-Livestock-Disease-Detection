package com.mifugocare.app.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.LinearLayout;

import androidx.appcompat.app.AppCompatActivity;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentManager;
import androidx.fragment.app.FragmentTransaction;

import com.mifugocare.app.R;
import com.mifugocare.app.fragments.HomeFragment;
import com.mifugocare.app.fragments.HistoryFragment;
import com.mifugocare.app.fragments.RecordsFragment;

public class MainActivity extends AppCompatActivity {
    
    private LinearLayout navDiagnosis, navHistory, navLivestock, navSettings;
    private int currentNavItem = 0; // 0 = diagnosis, 1 = history, 2 = livestock, 3 = settings
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
        
        initializeViews();
        setupClickListeners();
        
        // Load default fragment
        loadFragment(new HomeFragment());
        updateNavigationState(0);
    }
    
    private void initializeViews() {
        navDiagnosis = findViewById(R.id.nav_diagnosis);
        navHistory = findViewById(R.id.nav_history);
        navLivestock = findViewById(R.id.nav_livestock);
        navSettings = findViewById(R.id.nav_settings);
    }
    
    private void setupClickListeners() {
        navDiagnosis.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, DiagnosisActivity.class);
            startActivity(intent);
        });
        
        navHistory.setOnClickListener(v -> {
            loadFragment(new HistoryFragment());
            updateNavigationState(1);
        });
        
        navLivestock.setOnClickListener(v -> {
            loadFragment(new RecordsFragment());
            updateNavigationState(2);
        });
        
        navSettings.setOnClickListener(v -> {
            Intent intent = new Intent(MainActivity.this, SettingsActivity.class);
            startActivity(intent);
        });
    }
    
    private void loadFragment(Fragment fragment) {
        FragmentManager fragmentManager = getSupportFragmentManager();
        FragmentTransaction transaction = fragmentManager.beginTransaction();
        transaction.replace(R.id.fragment_container, fragment);
        transaction.commit();
    }
    
    private void updateNavigationState(int selectedItem) {
        currentNavItem = selectedItem;
        
        // Reset all navigation items
        resetNavigationItem(navDiagnosis, R.drawable.ic_camera_diagnose, R.string.nav_diagnosis);
        resetNavigationItem(navHistory, R.drawable.ic_history, R.string.nav_history);
        resetNavigationItem(navLivestock, R.drawable.ic_livestock, R.string.nav_livestock);
        resetNavigationItem(navSettings, R.drawable.ic_settings, R.string.nav_settings);
        
        // Highlight selected item
        switch (selectedItem) {
            case 0:
                highlightNavigationItem(navDiagnosis, R.drawable.ic_camera_diagnose, R.string.nav_diagnosis);
                break;
            case 1:
                highlightNavigationItem(navHistory, R.drawable.ic_history, R.string.nav_history);
                break;
            case 2:
                highlightNavigationItem(navLivestock, R.drawable.ic_livestock, R.string.nav_livestock);
                break;
            case 3:
                highlightNavigationItem(navSettings, R.drawable.ic_settings, R.string.nav_settings);
                break;
        }
    }
    
    private void resetNavigationItem(LinearLayout navItem, int iconRes, int textRes) {
        // Reset icon tint
        ((android.widget.ImageView) navItem.getChildAt(0)).setImageResource(iconRes);
        ((android.widget.ImageView) navItem.getChildAt(0)).setColorFilter(getColor(R.color.text_secondary));
        
        // Reset text color
        ((android.widget.TextView) navItem.getChildAt(1)).setTextColor(getColor(R.color.text_secondary));
    }
    
    private void highlightNavigationItem(LinearLayout navItem, int iconRes, int textRes) {
        // Highlight icon tint
        ((android.widget.ImageView) navItem.getChildAt(0)).setImageResource(iconRes);
        ((android.widget.ImageView) navItem.getChildAt(0)).setColorFilter(getColor(R.color.accent_primary));
        
        // Highlight text color
        ((android.widget.TextView) navItem.getChildAt(1)).setTextColor(getColor(R.color.accent_primary));
    }
}
