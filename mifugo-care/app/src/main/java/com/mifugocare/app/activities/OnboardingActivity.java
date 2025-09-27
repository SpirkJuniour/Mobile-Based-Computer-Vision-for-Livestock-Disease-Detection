package com.mifugocare.app.activities;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.LinearLayout;

import androidx.appcompat.app.AppCompatActivity;
import androidx.viewpager2.widget.ViewPager2;

import com.mifugocare.app.R;
import com.mifugocare.app.adapters.OnboardingAdapter;
import com.mifugocare.app.utils.PermissionUtils;
import com.mifugocare.app.utils.SharedPreferencesManager;

public class OnboardingActivity extends AppCompatActivity {
    
    private ViewPager2 viewPager;
    private Button btnPrevious, btnNext, btnSkip;
    private LinearLayout pageIndicators;
    private OnboardingAdapter adapter;
    private SharedPreferencesManager prefsManager;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_onboarding);
        
        prefsManager = new SharedPreferencesManager(this);
        
        initializeViews();
        setupViewPager();
        setupClickListeners();
        updateUI();
    }
    
    private void initializeViews() {
        viewPager = findViewById(R.id.view_pager);
        btnPrevious = findViewById(R.id.btn_previous);
        btnNext = findViewById(R.id.btn_next);
        btnSkip = findViewById(R.id.btn_skip);
        pageIndicators = findViewById(R.id.page_indicators);
    }
    
    private void setupViewPager() {
        adapter = new OnboardingAdapter();
        viewPager.setAdapter(adapter);
        
        viewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                super.onPageSelected(position);
                updateUI();
            }
        });
    }
    
    private void setupClickListeners() {
        btnSkip.setOnClickListener(v -> finishOnboarding());
        
        btnPrevious.setOnClickListener(v -> {
            if (viewPager.getCurrentItem() > 0) {
                viewPager.setCurrentItem(viewPager.getCurrentItem() - 1);
            }
        });
        
        btnNext.setOnClickListener(v -> {
            int currentItem = viewPager.getCurrentItem();
            if (currentItem < adapter.getItemCount() - 1) {
                viewPager.setCurrentItem(currentItem + 1);
            } else {
                finishOnboarding();
            }
        });
    }
    
    private void updateUI() {
        int currentItem = viewPager.getCurrentItem();
        int totalItems = adapter.getItemCount();
        
        // Update button visibility
        btnPrevious.setVisibility(currentItem > 0 ? View.VISIBLE : View.GONE);
        btnNext.setText(currentItem == totalItems - 1 ? "Get Started" : "Next");
        
        // Update page indicators
        updatePageIndicators(currentItem, totalItems);
    }
    
    private void updatePageIndicators(int currentPosition, int totalPages) {
        pageIndicators.removeAllViews();
        
        for (int i = 0; i < totalPages; i++) {
            View indicator = new View(this);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                i == currentPosition ? 24 : 8, 8
            );
            params.setMargins(4, 0, 4, 0);
            indicator.setLayoutParams(params);
            indicator.setBackgroundResource(i == currentPosition ? 
                R.drawable.indicator_active : R.drawable.indicator_inactive);
            pageIndicators.addView(indicator);
        }
    }
    
    private void finishOnboarding() {
        // Mark onboarding as completed
        prefsManager.setFirstLaunch(false);
        
        // Request permissions
        if (!PermissionUtils.hasAllRequiredPermissions(this)) {
            PermissionUtils.requestAllRequiredPermissions(this);
        }
        
        // Navigate to main activity
        Intent intent = new Intent(this, MainActivity.class);
        startActivity(intent);
        finish();
    }
    
    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        
        if (requestCode == PermissionUtils.CAMERA_PERMISSION_REQUEST_CODE) {
            if (PermissionUtils.arePermissionsGranted(grantResults)) {
                // Permissions granted, continue to main activity
                Intent intent = new Intent(this, MainActivity.class);
                startActivity(intent);
                finish();
            } else {
                // Permissions denied, show explanation
                // For now, continue anyway but with limited functionality
                Intent intent = new Intent(this, MainActivity.class);
                startActivity(intent);
                finish();
            }
        }
    }
}
