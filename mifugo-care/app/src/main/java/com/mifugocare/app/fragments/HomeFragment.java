package com.mifugocare.app.fragments;

import android.content.Intent;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.mifugocare.app.R;
import com.mifugocare.app.activities.DiagnosisActivity;
import com.mifugocare.app.database.AppDatabase;
import com.mifugocare.app.database.dao.DiagnosisDao;
import com.mifugocare.app.database.dao.LivestockDao;
import com.mifugocare.app.database.entities.Diagnosis;
import com.mifugocare.app.database.entities.Livestock;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class HomeFragment extends Fragment {
    
    private Button btnQuickDiagnosis;
    private TextView textWelcomeMessage;
    private TextView textTotalLivestock;
    private TextView textRecentDiagnoses;
    private TextView textLastDiagnosisDate;
    
    private LivestockDao livestockDao;
    private DiagnosisDao diagnosisDao;
    private SimpleDateFormat dateFormat;
    
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        AppDatabase database = AppDatabase.getDatabase(requireContext());
        livestockDao = database.livestockDao();
        diagnosisDao = database.diagnosisDao();
        dateFormat = new SimpleDateFormat("MMM dd, yyyy", Locale.getDefault());
    }
    
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_home, container, false);
        
        initializeViews(view);
        setupClickListeners();
        loadDashboardData();
        
        return view;
    }
    
    private void initializeViews(View view) {
        btnQuickDiagnosis = view.findViewById(R.id.btn_quick_diagnosis);
        textWelcomeMessage = view.findViewById(R.id.text_welcome_message);
        textTotalLivestock = view.findViewById(R.id.text_total_livestock);
        textRecentDiagnoses = view.findViewById(R.id.text_recent_diagnoses);
        textLastDiagnosisDate = view.findViewById(R.id.text_last_diagnosis_date);
    }
    
    private void setupClickListeners() {
        btnQuickDiagnosis.setOnClickListener(v -> {
            Intent intent = new Intent(getContext(), DiagnosisActivity.class);
            startActivity(intent);
        });
    }
    
    private void loadDashboardData() {
        // Load livestock count (assuming farmer ID 1 for demo)
        new Thread(() -> {
            int livestockCount = livestockDao.getLivestockCount(1);
            List<Diagnosis> recentDiagnoses = diagnosisDao.getAllDiagnoses();
            
            getActivity().runOnUiThread(() -> {
                textWelcomeMessage.setText(getString(R.string.msg_welcome));
                textTotalLivestock.setText("Mifugo: " + livestockCount);
                
                if (recentDiagnoses.isEmpty()) {
                    textRecentDiagnoses.setText("Uchunguzi: 0");
                    textLastDiagnosisDate.setText(getString(R.string.msg_start_diagnosis));
                } else {
                    textRecentDiagnoses.setText("Uchunguzi: " + recentDiagnoses.size());
                    Diagnosis lastDiagnosis = recentDiagnoses.get(0);
                    String lastDate = dateFormat.format(new Date(lastDiagnosis.getDiagnosisDate()));
                    textLastDiagnosisDate.setText("Uchunguzi wa mwisho: " + lastDate);
                }
            });
        }).start();
    }
    
    @Override
    public void onResume() {
        super.onResume();
        loadDashboardData(); // Refresh data when fragment becomes visible
    }
}
