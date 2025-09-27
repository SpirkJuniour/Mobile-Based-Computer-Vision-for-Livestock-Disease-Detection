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
import com.mifugocare.app.adapters.LivestockRecordsAdapter;
import com.mifugocare.app.database.AppDatabase;
import com.mifugocare.app.database.dao.LivestockDao;
import com.mifugocare.app.database.entities.Livestock;

import java.util.List;

public class RecordsFragment extends Fragment {
    
    private RecyclerView recyclerViewRecords;
    private TextView textEmptyState;
    private LivestockRecordsAdapter adapter;
    private LivestockDao livestockDao;
    
    @Override
    public void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        AppDatabase database = AppDatabase.getDatabase(requireContext());
        livestockDao = database.livestockDao();
    }
    
    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        View view = inflater.inflate(R.layout.fragment_records, container, false);
        
        initializeViews(view);
        setupRecyclerView();
        setupClickListener();
        loadLivestockRecords();
        
        return view;
    }
    
    private void initializeViews(View view) {
        recyclerViewRecords = view.findViewById(R.id.recycler_view_records);
        textEmptyState = view.findViewById(R.id.text_empty_state);
    }
    
    private void setupRecyclerView() {
        adapter = new LivestockRecordsAdapter();
        recyclerViewRecords.setLayoutManager(new LinearLayoutManager(getContext()));
        recyclerViewRecords.setAdapter(adapter);
    }
    
    private void setupClickListener() {
        adapter.setOnLivestockClickListener(new LivestockRecordsAdapter.OnLivestockClickListener() {
            @Override
            public void onLivestockClick(Livestock livestock) {
                // Handle livestock click - could show detailed view
                showLivestockDetails(livestock);
            }
            
            @Override
            public void onLivestockLongClick(Livestock livestock) {
                // Handle long click - could show context menu
                showLivestockContextMenu(livestock);
            }
        });
    }
    
    private void loadLivestockRecords() {
        new Thread(() -> {
            // Assuming farmer ID 1 for demo - in real app, get from logged-in user
            List<Livestock> livestockList = livestockDao.getLivestockByFarmer(1);
            getActivity().runOnUiThread(() -> {
                if (livestockList.isEmpty()) {
                    textEmptyState.setVisibility(View.VISIBLE);
                    recyclerViewRecords.setVisibility(View.GONE);
                } else {
                    textEmptyState.setVisibility(View.GONE);
                    recyclerViewRecords.setVisibility(View.VISIBLE);
                    adapter.updateLivestockList(livestockList);
                }
            });
        }).start();
    }
    
    private void showLivestockDetails(Livestock livestock) {
        // TODO: Implement livestock details dialog or activity
        // For now, just show a toast
        if (getContext() != null) {
            android.widget.Toast.makeText(getContext(), 
                "Mifugo: " + livestock.getSpecies() + " - " + livestock.getTagNumber(), 
                android.widget.Toast.LENGTH_SHORT).show();
        }
    }
    
    private void showLivestockContextMenu(Livestock livestock) {
        // TODO: Implement context menu for livestock actions
        // Could include options like: Edit, Delete, Diagnose, View History, etc.
    }
    
    @Override
    public void onResume() {
        super.onResume();
        loadLivestockRecords(); // Refresh data when fragment becomes visible
    }
}
