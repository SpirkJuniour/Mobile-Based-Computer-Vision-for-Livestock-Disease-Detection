package com.mifugocare.app.fragments;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.mifugocare.app.R;
import com.mifugocare.app.adapters.DiagnosisHistoryAdapter;
import com.mifugocare.app.database.AppDatabase;
import com.mifugocare.app.database.dao.DiagnosisDao;
import com.mifugocare.app.database.entities.Diagnosis;

import java.util.List;

public class HistoryFragment extends Fragment {
    
    private RecyclerView recyclerViewHistory;
    private TextView textEmptyState;
    private DiagnosisHistoryAdapter adapter;
    private DiagnosisDao diagnosisDao;
    
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        AppDatabase database = AppDatabase.getDatabase(requireContext());
        diagnosisDao = database.diagnosisDao();
    }
    
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_history, container, false);
        
        initializeViews(view);
        setupRecyclerView();
        setupClickListener();
        loadDiagnosisHistory();
        
        return view;
    }
    
    private void initializeViews(View view) {
        recyclerViewHistory = view.findViewById(R.id.recycler_view_history);
        textEmptyState = view.findViewById(R.id.text_empty_state);
    }
    
    private void setupRecyclerView() {
        adapter = new DiagnosisHistoryAdapter();
        recyclerViewHistory.setLayoutManager(new LinearLayoutManager(getContext()));
        recyclerViewHistory.setAdapter(adapter);
    }
    
    private void setupClickListener() {
        adapter.setOnDiagnosisClickListener(new DiagnosisHistoryAdapter.OnDiagnosisClickListener() {
            @Override
            public void onDiagnosisClick(Diagnosis diagnosis) {
                // Handle diagnosis click - could show detailed view
                showDiagnosisDetails(diagnosis);
            }
            
            @Override
            public void onDiagnosisLongClick(Diagnosis diagnosis) {
                // Handle long click - could show context menu
                showDiagnosisContextMenu(diagnosis);
            }
        });
    }
    
    private void loadDiagnosisHistory() {
        new Thread(() -> {
            List<Diagnosis> diagnoses = diagnosisDao.getAllDiagnoses();
            getActivity().runOnUiThread(() -> {
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
    
    private void showDiagnosisDetails(Diagnosis diagnosis) {
        // TODO: Implement diagnosis details dialog or activity
        // For now, just show a toast
        if (getContext() != null) {
            android.widget.Toast.makeText(getContext(), 
                "Diagnosis: " + diagnosis.getDiagnosisResult(), 
                android.widget.Toast.LENGTH_SHORT).show();
        }
    }
    
    private void showDiagnosisContextMenu(Diagnosis diagnosis) {
        // TODO: Implement context menu for diagnosis actions
        // Could include options like: Edit, Delete, Share, etc.
    }
    
    @Override
    public void onResume() {
        super.onResume();
        loadDiagnosisHistory(); // Refresh data when fragment becomes visible
    }
}
