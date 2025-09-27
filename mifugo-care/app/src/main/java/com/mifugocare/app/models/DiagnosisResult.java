package com.mifugocare.app.models;

import java.util.List;

public class DiagnosisResult {
    
    private String diseaseName;
    private float confidence;
    private String severity;
    private String symptoms;
    private String treatment;
    private String prevention;
    private boolean isContagious;
    private String affectedBodyParts;
    private List<String> recommendedActions;
    private String veterinarianAdvice;
    private String imagePath;
    private long timestamp;
    
    // Constructors
    public DiagnosisResult() {
        this.timestamp = System.currentTimeMillis();
    }
    
    public DiagnosisResult(String diseaseName, float confidence, String severity) {
        this();
        this.diseaseName = diseaseName;
        this.confidence = confidence;
        this.severity = severity;
    }
    
    // Getters and Setters
    public String getDiseaseName() {
        return diseaseName;
    }
    
    public void setDiseaseName(String diseaseName) {
        this.diseaseName = diseaseName;
    }
    
    public float getConfidence() {
        return confidence;
    }
    
    public void setConfidence(float confidence) {
        this.confidence = confidence;
    }
    
    public String getSeverity() {
        return severity;
    }
    
    public void setSeverity(String severity) {
        this.severity = severity;
    }
    
    public String getSymptoms() {
        return symptoms;
    }
    
    public void setSymptoms(String symptoms) {
        this.symptoms = symptoms;
    }
    
    public String getTreatment() {
        return treatment;
    }
    
    public void setTreatment(String treatment) {
        this.treatment = treatment;
    }
    
    public String getPrevention() {
        return prevention;
    }
    
    public void setPrevention(String prevention) {
        this.prevention = prevention;
    }
    
    public boolean isContagious() {
        return isContagious;
    }
    
    public void setContagious(boolean contagious) {
        isContagious = contagious;
    }
    
    public String getAffectedBodyParts() {
        return affectedBodyParts;
    }
    
    public void setAffectedBodyParts(String affectedBodyParts) {
        this.affectedBodyParts = affectedBodyParts;
    }
    
    public List<String> getRecommendedActions() {
        return recommendedActions;
    }
    
    public void setRecommendedActions(List<String> recommendedActions) {
        this.recommendedActions = recommendedActions;
    }
    
    public String getVeterinarianAdvice() {
        return veterinarianAdvice;
    }
    
    public void setVeterinarianAdvice(String veterinarianAdvice) {
        this.veterinarianAdvice = veterinarianAdvice;
    }
    
    public String getImagePath() {
        return imagePath;
    }
    
    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }
    
    public long getTimestamp() {
        return timestamp;
    }
    
    public void setTimestamp(long timestamp) {
        this.timestamp = timestamp;
    }
    
    // Helper methods
    public boolean isHighConfidence() {
        return confidence >= 0.8f;
    }
    
    public boolean isMediumConfidence() {
        return confidence >= 0.5f && confidence < 0.8f;
    }
    
    public boolean isLowConfidence() {
        return confidence < 0.5f;
    }
    
    public String getConfidenceLevel() {
        if (isHighConfidence()) {
            return "High";
        } else if (isMediumConfidence()) {
            return "Medium";
        } else {
            return "Low";
        }
    }
    
    public String getConfidencePercentage() {
        return String.format("%.1f%%", confidence * 100);
    }
}
