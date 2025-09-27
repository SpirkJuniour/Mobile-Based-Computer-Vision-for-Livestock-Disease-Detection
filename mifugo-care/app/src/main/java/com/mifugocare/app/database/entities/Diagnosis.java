package com.mifugocare.app.database.entities;

import androidx.room.Entity;
import androidx.room.PrimaryKey;
import androidx.room.ForeignKey;
import androidx.room.Index;

@Entity(tableName = "diagnoses",
        foreignKeys = {
            @ForeignKey(entity = Livestock.class,
                       parentColumns = "livestockId",
                       childColumns = "livestockId",
                       onDelete = ForeignKey.CASCADE),
            @ForeignKey(entity = Disease.class,
                       parentColumns = "diseaseId",
                       childColumns = "diseaseId",
                       onDelete = ForeignKey.CASCADE)
        },
        indices = {@Index("livestockId"), @Index("diseaseId")})
public class Diagnosis {
    @PrimaryKey(autoGenerate = true)
    public int diagnosisId;
    
    public int livestockId;
    public int diseaseId;
    public String imagePath; // Path to the captured image
    public String diagnosisResult; // ML model prediction
    public float confidence; // Confidence score (0.0 - 1.0)
    public String status; // "Confirmed", "Suspected", "Negative"
    public String notes;
    public String veterinarianNotes;
    public String treatmentPrescribed;
    public String followUpDate;
    public boolean isTreated;
    public String location;
    public String weatherConditions;
    public long diagnosisDate;
    public long lastUpdated;
    
    // Constructors
    public Diagnosis() {
        this.diagnosisDate = System.currentTimeMillis();
        this.lastUpdated = System.currentTimeMillis();
        this.isTreated = false;
    }
    
    public Diagnosis(int livestockId, String imagePath, String diagnosisResult, 
                    float confidence, String status) {
        this();
        this.livestockId = livestockId;
        this.imagePath = imagePath;
        this.diagnosisResult = diagnosisResult;
        this.confidence = confidence;
        this.status = status;
    }
    
    // Getters and Setters
    public int getDiagnosisId() { return diagnosisId; }
    public void setDiagnosisId(int diagnosisId) { this.diagnosisId = diagnosisId; }
    
    public int getLivestockId() { return livestockId; }
    public void setLivestockId(int livestockId) { this.livestockId = livestockId; }
    
    public int getDiseaseId() { return diseaseId; }
    public void setDiseaseId(int diseaseId) { this.diseaseId = diseaseId; }
    
    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    
    public String getDiagnosisResult() { return diagnosisResult; }
    public void setDiagnosisResult(String diagnosisResult) { this.diagnosisResult = diagnosisResult; }
    
    public float getConfidence() { return confidence; }
    public void setConfidence(float confidence) { this.confidence = confidence; }
    
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    
    public String getVeterinarianNotes() { return veterinarianNotes; }
    public void setVeterinarianNotes(String veterinarianNotes) { this.veterinarianNotes = veterinarianNotes; }
    
    public String getTreatmentPrescribed() { return treatmentPrescribed; }
    public void setTreatmentPrescribed(String treatmentPrescribed) { this.treatmentPrescribed = treatmentPrescribed; }
    
    public String getFollowUpDate() { return followUpDate; }
    public void setFollowUpDate(String followUpDate) { this.followUpDate = followUpDate; }
    
    public boolean isTreated() { return isTreated; }
    public void setTreated(boolean treated) { isTreated = treated; }
    
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    
    public String getWeatherConditions() { return weatherConditions; }
    public void setWeatherConditions(String weatherConditions) { this.weatherConditions = weatherConditions; }
    
    public long getDiagnosisDate() { return diagnosisDate; }
    public void setDiagnosisDate(long diagnosisDate) { this.diagnosisDate = diagnosisDate; }
    
    public long getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(long lastUpdated) { this.lastUpdated = lastUpdated; }
}
