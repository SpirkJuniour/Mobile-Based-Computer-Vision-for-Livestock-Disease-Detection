package com.mifugocare.app.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mifugocare.app.R;

public class OnboardingAdapter extends RecyclerView.Adapter<OnboardingAdapter.OnboardingViewHolder> {
    
    private static final int[] ILLUSTRATIONS = {
        R.drawable.ic_camera_diagnose,
        R.drawable.ic_livestock,
        R.drawable.ic_history
    };
    
    private static final String[] TITLES = {
        "Smart Diagnosis",
        "Livestock Management",
        "Track History"
    };
    
    private static final String[] DESCRIPTIONS = {
        "Take a photo of your livestock and get instant AI-powered disease detection with confidence scores and treatment recommendations.",
        "Manage your livestock records, track health status, and organize your animals by species, breed, and location.",
        "Keep a complete history of all diagnoses, treatments, and health assessments for better livestock management."
    };
    
    @NonNull
    @Override
    public OnboardingViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_onboarding, parent, false);
        return new OnboardingViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull OnboardingViewHolder holder, int position) {
        holder.bind(position);
    }
    
    @Override
    public int getItemCount() {
        return TITLES.length;
    }
    
    static class OnboardingViewHolder extends RecyclerView.ViewHolder {
        private ImageView illustration;
        private TextView title;
        private TextView description;
        private LinearLayout featuresList;
        
        public OnboardingViewHolder(@NonNull View itemView) {
            super(itemView);
            illustration = itemView.findViewById(R.id.illustration);
            title = itemView.findViewById(R.id.title);
            description = itemView.findViewById(R.id.description);
            featuresList = itemView.findViewById(R.id.features_list);
        }
        
        public void bind(int position) {
            illustration.setImageResource(ILLUSTRATIONS[position]);
            title.setText(TITLES[position]);
            description.setText(DESCRIPTIONS[position]);
            
            // Show/hide features list based on position
            if (position == 0) {
                featuresList.setVisibility(View.VISIBLE);
            } else {
                featuresList.setVisibility(View.GONE);
            }
        }
    }
}
