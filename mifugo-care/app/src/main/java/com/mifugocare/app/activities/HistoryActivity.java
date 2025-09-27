package com.mifugocare.app.activities;

import android.os.Bundle;
import android.view.View;
import android.widget.TextView;

import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.mifugocare.app.R;
import com.mifugocare.app.adapters.DiagnosisHistoryAdapter;
import com.mifugocare.app.database.AppDatabase;
import com.mifugocare.app.database.dao.DiagnosisDao;
import com.mifugocare.app.database.entities.Diagnosis;

import java.util.List;

public class HistoryActivity extends AppCompatActivity {
    
    private RecyclerView recyclerViewHistory;
    private TextView textEmptyState;
    private DiagnosisHistoryAdapter adapter;
    private DiagnosisDao diagnosisDao;
    
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_history);
        
        initializeViews();
        setupDatabase();
        setupRecyclerView();
        loadDiagnosisHistory();
    }
    
    private void initializeViews() {
        recyclerViewHistory = findViewById(R.id.recycler_view_history);
        textEmptyState = findViewById(R.id.text_empty_state);
        
        if (getSupportActionBar() != null) {
            getSupportActionBar().setTitle(getString(R.string.title_history_activity));
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
        }
    }
    
    private void setupDatabase() {
        AppDatabase database = AppDatabase.getDatabase(this);
        diagnosisDao = database.diagnosisDao();
    }
    
    private void setupRecyclerView() {
        adapter = new DiagnosisHistoryAdapter();
        recyclerViewHistory.setLayoutManager(new LinearLayoutManager(this));
        recyclerViewHistory.setAdapter(adapter);
    }
    
    private void loadDiagnosisHistory() {
        new Thread(() -> {
            List<Diagnosis> diagnoses = diagnosisDao.getAllDiagnoses();
            runOnUiThread(() -> {
                if (diagnoses.isEmpty()) {
                    textEmptyState.setVisibility(View.VISIBLE);
                    recyclerViewHistory.setVisibility(View.GONE);
                } else {
                    textEmptyState.setVisibility(View.GONE);
                    recyclerViewHistory.setVisibility(View.VISIBLE);
                    adapter.updateDiagnoses(diagnoses);
                }
            });
        }).start();
    }
    
    @Override
    public boolean onSupportNavigateUp() {
        onBackPressed();
        return true;
    }
}
