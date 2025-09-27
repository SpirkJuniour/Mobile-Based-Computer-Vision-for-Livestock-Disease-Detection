package com.mifugocare.app.adapters;

import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.mifugocare.app.R;
import com.mifugocare.app.database.entities.Livestock;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.Locale;

public class LivestockRecordsAdapter extends RecyclerView.Adapter<LivestockRecordsAdapter.LivestockViewHolder> {
    
    private List<Livestock> livestockList;
    private OnLivestockClickListener clickListener;
    private SimpleDateFormat dateFormat;
    
    public interface OnLivestockClickListener {
        void onLivestockClick(Livestock livestock);
        void onLivestockLongClick(Livestock livestock);
    }
    
    public LivestockRecordsAdapter() {
        this.livestockList = new ArrayList<>();
        this.dateFormat = new SimpleDateFormat("MMM dd, yyyy", Locale.getDefault());
    }
    
    public void setOnLivestockClickListener(OnLivestockClickListener listener) {
        this.clickListener = listener;
    }
    
    public void updateLivestockList(List<Livestock> newLivestockList) {
        this.livestockList.clear();
        this.livestockList.addAll(newLivestockList);
        notifyDataSetChanged();
    }
    
    @NonNull
    @Override
    public LivestockViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {
        View view = LayoutInflater.from(parent.getContext())
                .inflate(R.layout.item_livestock_record, parent, false);
        return new LivestockViewHolder(view);
    }
    
    @Override
    public void onBindViewHolder(@NonNull LivestockViewHolder holder, int position) {
        Livestock livestock = livestockList.get(position);
        holder.bind(livestock);
    }
    
    @Override
    public int getItemCount() {
        return livestockList.size();
    }
    
    class LivestockViewHolder extends RecyclerView.ViewHolder {
        private ImageView imageLivestock;
        private TextView textSpecies;
        private TextView textBreed;
        private TextView textTagNumber;
        private TextView textAge;
        private TextView textGender;
        private TextView textHealthStatus;
        private TextView textDateAdded;
        private View healthIndicator;
        
        public LivestockViewHolder(@NonNull View itemView) {
            super(itemView);
            imageLivestock = itemView.findViewById(R.id.image_livestock);
            textSpecies = itemView.findViewById(R.id.text_species);
            textBreed = itemView.findViewById(R.id.text_breed);
            textTagNumber = itemView.findViewById(R.id.text_tag_number);
            textAge = itemView.findViewById(R.id.text_age);
            textGender = itemView.findViewById(R.id.text_gender);
            textHealthStatus = itemView.findViewById(R.id.text_health_status);
            textDateAdded = itemView.findViewById(R.id.text_date_added);
            healthIndicator = itemView.findViewById(R.id.health_indicator);
            
            itemView.setOnClickListener(v -> {
                if (clickListener != null) {
                    int position = getAdapterPosition();
                    if (position != RecyclerView.NO_POSITION) {
                        clickListener.onLivestockClick(livestockList.get(position));
                    }
                }
            });
            
            itemView.setOnLongClickListener(v -> {
                if (clickListener != null) {
                    int position = getAdapterPosition();
                    if (position != RecyclerView.NO_POSITION) {
                        clickListener.onLivestockLongClick(livestockList.get(position));
                        return true;
                    }
                }
                return false;
            });
        }
        
        public void bind(Livestock livestock) {
            // Set livestock image based on species
            int imageResource = getSpeciesImage(livestock.getSpecies());
            imageLivestock.setImageResource(imageResource);
            
            // Set species and breed
            textSpecies.setText(livestock.getSpecies() != null ? livestock.getSpecies() : "Unknown");
            textBreed.setText(livestock.getBreed() != null ? livestock.getBreed() : "Unknown Breed");
            
            // Set tag number
            textTagNumber.setText(livestock.getTagNumber() != null ? 
                    "Tag: " + livestock.getTagNumber() : "No Tag");
            
            // Set age
            textAge.setText(livestock.getAge() != null ? 
                    "Age: " + livestock.getAge() : "Age: Unknown");
            
            // Set gender
            textGender.setText(livestock.getGender() != null ? 
                    livestock.getGender() : "Unknown");
            
            // Set health status with indicator
            String healthStatus = livestock.getHealthStatus() != null ? 
                    livestock.getHealthStatus() : "Unknown";
            textHealthStatus.setText(healthStatus);
            
            // Set health indicator color
            int healthColor = getHealthStatusColor(healthStatus);
            healthIndicator.setBackgroundColor(healthColor);
            
            // Set date added
            String dateString = dateFormat.format(new Date(livestock.getDateAdded()));
            textDateAdded.setText("Added: " + dateString);
        }
        
        private int getSpeciesImage(String species) {
            if (species == null) return R.drawable.ic_cow;
            
            switch (species.toLowerCase()) {
                case "cow":
                case "cattle":
                    return R.drawable.ic_cow;
                case "goat":
                    return R.drawable.ic_cow; // You can add specific icons later
                case "sheep":
                    return R.drawable.ic_cow; // You can add specific icons later
                default:
                    return R.drawable.ic_cow;
            }
        }
        
        private int getHealthStatusColor(String status) {
            if (status == null) return itemView.getContext().getColor(android.R.color.darker_gray);
            
            switch (status.toLowerCase()) {
                case "healthy":
                    return itemView.getContext().getColor(android.R.color.holo_green_light);
                case "sick":
                case "diseased":
                    return itemView.getContext().getColor(android.R.color.holo_red_light);
                case "recovering":
                    return itemView.getContext().getColor(android.R.color.holo_orange_light);
                default:
                    return itemView.getContext().getColor(android.R.color.darker_gray);
            }
        }
    }
}
