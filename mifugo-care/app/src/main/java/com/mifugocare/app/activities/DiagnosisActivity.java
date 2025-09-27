package com.mifugocare.app.activities;

import android.content.Intent;
import android.os.Bundle;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;

import com.mifugocare.app.R;

public class DiagnosisActivity extends AppCompatActivity {
    
    private Button btnTakePhoto, btnSelectFromGallery;
    private ImageView imagePreview;
    private TextView textInstructions;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_diagnosis);
        
        initializeViews();
        setupClickListeners();
        setupUI();
    }
    
    private void initializeViews() {
        btnTakePhoto = findViewById(R.id.btn_take_photo);
        btnSelectFromGallery = findViewById(R.id.btn_select_gallery);
        imagePreview = findViewById(R.id.image_preview);
        textInstructions = findViewById(R.id.text_instructions);
    }
    
    private void setupClickListeners() {
        btnTakePhoto.setOnClickListener(v -> {
            Intent intent = new Intent(DiagnosisActivity.this, CameraActivity.class);
            startActivity(intent);
        });
        
        btnSelectFromGallery.setOnClickListener(v -> {
            // Open gallery picker
            Intent intent = new Intent(Intent.ACTION_PICK);
            intent.setType("image/*");
            startActivityForResult(intent, 1001);
        });
    }
    
    private void setupUI() {
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(getString(R.string.title_diagnosis_activity));
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
    }
    
    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }
}
