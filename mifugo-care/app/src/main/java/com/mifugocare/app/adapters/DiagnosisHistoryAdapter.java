package com.mifugocare.app.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.bumptech.glide.Glide;
import com.mifugocare.app.R;
import com.mifugocare.app.database.entities.Diagnosis;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class DiagnosisHistoryAdapter extends RecyclerView.Adapter<DiagnosisHistoryAdapter.DiagnosisViewHolder> {
    
    private List<Diagnosis> diagnoses;
    private OnDiagnosisClickListener clickListener;
    private SimpleDateFormat dateFormat;
    
    public interface OnDiagnosisClickListener {
        void onDiagnosisClick(Diagnosis diagnosis);
        void onDiagnosisLongClick(Diagnosis diagnosis);
    }
    
    public DiagnosisHistoryAdapter() {
        this.diagnoses = new ArrayList<>();
        this.dateFormat = new SimpleDateFormat("MMM dd, yyyy HH:mm", Locale.getDefault());
    }
    
    public void setOnDiagnosisClickListener(OnDiagnosisClickListener listener) {
        this.clickListener = listener;
    }
    
    public void updateDiagnoses(List<Diagnosis> newDiagnoses) {
        this.diagnoses.clear();
        this.diagnoses.addAll(newDiagnoses);
        notifyDataSetChanged();
    }
    
    @NonNull
    @Override
    public DiagnosisViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_diagnosis_history, parent, false);
        return new DiagnosisViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull DiagnosisViewHolder holder, int position) {
        Diagnosis diagnosis = diagnoses.get(position);
        holder.bind(diagnosis);
    }
    
    @Override
    public int getItemCount() {
        return diagnoses.size();
    }
    
    class DiagnosisViewHolder extends RecyclerView.ViewHolder {
        private ImageView imageDiagnosis;
        private TextView textDiseaseName;
        private TextView textConfidence;
        private TextView textStatus;
        private TextView textDate;
        private TextView textLivestock;
        private View statusIndicator;
        
        public DiagnosisViewHolder(@NonNull View itemView) {
            super(itemView);
            imageDiagnosis = itemView.findViewById(R.id.image_diagnosis);
            textDiseaseName = itemView.findViewById(R.id.text_disease_name);
            textConfidence = itemView.findViewById(R.id.text_confidence);
            textStatus = itemView.findViewById(R.id.text_status);
            textDate = itemView.findViewById(R.id.text_date);
            textLivestock = itemView.findViewById(R.id.text_livestock);
            statusIndicator = itemView.findViewById(R.id.status_indicator);
            
            itemView.setOnClickListener(v -> {
                if (clickListener != null) {
                    int position = getAdapterPosition();
                    if (position != RecyclerView.NO_POSITION) {
                        clickListener.onDiagnosisClick(diagnoses.get(position));
                    }
                }
            });
            
            itemView.setOnLongClickListener(v -> {
                if (clickListener != null) {
                    int position = getAdapterPosition();
                    if (position != RecyclerView.NO_POSITION) {
                        clickListener.onDiagnosisLongClick(diagnoses.get(position));
                        return true;
                    }
                }
                return false;
            });
        }
        
        public void bind(Diagnosis diagnosis) {
            // Load diagnosis image
            if (diagnosis.getImagePath() != null && !diagnosis.getImagePath().isEmpty()) {
                Glide.with(itemView.getContext())
                        .load(diagnosis.getImagePath())
                        .placeholder(R.drawable.ic_cow)
                        .error(R.drawable.ic_cow)
                        .into(imageDiagnosis);
            } else {
                imageDiagnosis.setImageResource(R.drawable.ic_cow);
            }
            
            // Set disease name
            textDiseaseName.setText(diagnosis.getDiagnosisResult() != null ? 
                    diagnosis.getDiagnosisResult() : "Unknown Disease");
            
            // Set confidence score
            float confidence = diagnosis.getConfidence();
            textConfidence.setText(String.format(Locale.getDefault(), "%.1f%%", confidence * 100));
            
            // Set status with color indicator
            String status = diagnosis.getStatus() != null ? diagnosis.getStatus() : "Unknown";
            textStatus.setText(status);
            
            // Set status indicator color
            int statusColor = getStatusColor(status);
            statusIndicator.setBackgroundColor(statusColor);
            
            // Set date
            String dateString = dateFormat.format(new Date(diagnosis.getDiagnosisDate()));
            textDate.setText(dateString);
            
            // Set livestock info (you might want to fetch this from database)
            textLivestock.setText("Livestock ID: " + diagnosis.getLivestockId());
        }
        
        private int getStatusColor(String status) {
            switch (status.toLowerCase()) {
                case "confirmed":
                    return itemView.getContext().getColor(android.R.color.holo_red_light);
                case "suspected":
                    return itemView.getContext().getColor(android.R.color.holo_orange_light);
                case "negative":
                    return itemView.getContext().getColor(android.R.color.holo_green_light);
                default:
                    return itemView.getContext().getColor(android.R.color.darker_gray);
            }
        }
    }
}
