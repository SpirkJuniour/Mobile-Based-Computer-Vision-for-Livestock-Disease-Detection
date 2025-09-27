package com.mifugocare.app.database.entities;

import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "diseases")
public class Disease {
    @PrimaryKey(autoGenerate = true)
    public int diseaseId;
    
    public String diseaseName;
    public String scientificName;
    public String species; // Which livestock species this affects
    public String symptoms;
    public String causes;
    public String prevention;
    public String treatment;
    public String severity; // "Low", "Medium", "High", "Critical"
    public String contagious; // "Yes", "No", "Unknown"
    public String mortalityRate;
    public String affectedBodyParts;
    public String seasonality;
    public String imageUrl;
    public String modelConfidence; // ML model confidence threshold
    public long dateAdded;
    public long lastUpdated;
    
    // Constructors
    public Disease() {
        this.dateAdded = System.currentTimeMillis();
        this.lastUpdated = System.currentTimeMillis();
    }
    
    public Disease(String diseaseName, String species, String symptoms, 
                  String treatment, String severity) {
        this();
        this.diseaseName = diseaseName;
        this.species = species;
        this.symptoms = symptoms;
        this.treatment = treatment;
        this.severity = severity;
    }
    
    // Getters and Setters
    public int getDiseaseId() { return diseaseId; }
    public void setDiseaseId(int diseaseId) { this.diseaseId = diseaseId; }
    
    public String getDiseaseName() { return diseaseName; }
    public void setDiseaseName(String diseaseName) { this.diseaseName = diseaseName; }
    
    public String getScientificName() { return scientificName; }
    public void setScientificName(String scientificName) { this.scientificName = scientificName; }
    
    public String getSpecies() { return species; }
    public void setSpecies(String species) { this.species = species; }
    
    public String getSymptoms() { return symptoms; }
    public void setSymptoms(String symptoms) { this.symptoms = symptoms; }
    
    public String getCauses() { return causes; }
    public void setCauses(String causes) { this.causes = causes; }
    
    public String getPrevention() { return prevention; }
    public void setPrevention(String prevention) { this.prevention = prevention; }
    
    public String getTreatment() { return treatment; }
    public void setTreatment(String treatment) { this.treatment = treatment; }
    
    public String getSeverity() { return severity; }
    public void setSeverity(String severity) { this.severity = severity; }
    
    public String getContagious() { return contagious; }
    public void setContagious(String contagious) { this.contagious = contagious; }
    
    public String getMortalityRate() { return mortalityRate; }
    public void setMortalityRate(String mortalityRate) { this.mortalityRate = mortalityRate; }
    
    public String getAffectedBodyParts() { return affectedBodyParts; }
    public void setAffectedBodyParts(String affectedBodyParts) { this.affectedBodyParts = affectedBodyParts; }
    
    public String getSeasonality() { return seasonality; }
    public void setSeasonality(String seasonality) { this.seasonality = seasonality; }
    
    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }
    
    public String getModelConfidence() { return modelConfidence; }
    public void setModelConfidence(String modelConfidence) { this.modelConfidence = modelConfidence; }
    
    public long getDateAdded() { return dateAdded; }
    public void setDateAdded(long dateAdded) { this.dateAdded = dateAdded; }
    
    public long getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(long lastUpdated) { this.lastUpdated = lastUpdated; }
}
