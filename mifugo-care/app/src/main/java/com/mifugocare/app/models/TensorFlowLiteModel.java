package com.mifugocare.app.models;

import android.content.Context;
import android.content.res.AssetManager;

import org.tensorflow.lite.Interpreter;
import org.tensorflow.lite.support.common.FileUtil;

import java.io.FileInputStream;
import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.util.ArrayList;
import java.util.List;

public class TensorFlowLiteModel {
    
    private Interpreter interpreter;
    private Context context;
    private static final String MODEL_FILE = "models/livestock_disease_model.tflite";
    private static final String DISEASES_FILE = "diseases/disease_profiles.json";
    
    // Model input/output dimensions
    private static final int INPUT_SIZE = 224;
    private static final int NUM_CLASSES = 10; // Adjust based on your model
    
    public TensorFlowLiteModel(Context context) {
        this.context = context;
        loadModel();
    }
    
    private void loadModel() {
        try {
            MappedByteBuffer modelBuffer = loadModelFile();
            Interpreter.Options options = new Interpreter.Options();
            options.setNumThreads(4); // Use 4 threads for inference
            interpreter = new Interpreter(modelBuffer, options);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    
    private MappedByteBuffer loadModelFile() throws IOException {
        AssetManager assetManager = context.getAssets();
        FileInputStream inputStream = new FileInputStream(assetManager.openFd(MODEL_FILE).getFileDescriptor());
        FileChannel fileChannel = inputStream.getChannel();
        long startOffset = assetManager.openFd(MODEL_FILE).getStartOffset();
        long declaredLength = assetManager.openFd(MODEL_FILE).getDeclaredLength();
        return fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength);
    }
    
    public DiagnosisResult predictDisease(ByteBuffer imageBuffer) {
        if (interpreter == null) {
            return null;
        }
        
        // Prepare input array
        float[][][][] input = new float[1][INPUT_SIZE][INPUT_SIZE][3];
        
        // Convert ByteBuffer to float array
        imageBuffer.rewind();
        for (int i = 0; i < INPUT_SIZE; i++) {
            for (int j = 0; j < INPUT_SIZE; j++) {
                for (int k = 0; k < 3; k++) {
                    input[0][i][j][k] = imageBuffer.getFloat();
                }
            }
        }
        
        // Prepare output array
        float[][] output = new float[1][NUM_CLASSES];
        
        // Run inference
        interpreter.run(input, output);
        
        // Process results
        return processOutput(output[0]);
    }
    
    private DiagnosisResult processOutput(float[] predictions) {
        // Find the class with highest confidence
        int maxIndex = 0;
        float maxConfidence = 0;
        
        for (int i = 0; i < predictions.length; i++) {
            if (predictions[i] > maxConfidence) {
                maxConfidence = predictions[i];
                maxIndex = i;
            }
        }
        
        // Apply softmax to get probabilities
        float[] probabilities = applySoftmax(predictions);
        maxConfidence = probabilities[maxIndex];
        
        // Map class index to disease name
        String diseaseName = getDiseaseName(maxIndex);
        String severity = getDiseaseSeverity(diseaseName);
        
        DiagnosisResult result = new DiagnosisResult();
        result.setDiseaseName(diseaseName);
        result.setConfidence(maxConfidence);
        result.setSeverity(severity);
        result.setSymptoms(getDiseaseSymptoms(diseaseName));
        result.setTreatment(getDiseaseTreatment(diseaseName));
        result.setPrevention(getDiseasePrevention(diseaseName));
        result.setContagious(isDiseaseContagious(diseaseName));
        result.setAffectedBodyParts(getAffectedBodyParts(diseaseName));
        
        return result;
    }
    
    private float[] applySoftmax(float[] logits) {
        float[] probabilities = new float[logits.length];
        float maxLogit = Float.NEGATIVE_INFINITY;
        
        // Find maximum logit for numerical stability
        for (float logit : logits) {
            maxLogit = Math.max(maxLogit, logit);
        }
        
        // Calculate sum of exponentials
        float sum = 0;
        for (int i = 0; i < logits.length; i++) {
            probabilities[i] = (float) Math.exp(logits[i] - maxLogit);
            sum += probabilities[i];
        }
        
        // Normalize to get probabilities
        for (int i = 0; i < probabilities.length; i++) {
            probabilities[i] /= sum;
        }
        
        return probabilities;
    }
    
    private String getDiseaseName(int classIndex) {
        // Map class indices to disease names
        // This should match your model's training classes
        String[] diseaseNames = {
            "Foot and Mouth Disease",
            "Mastitis",
            "Lumpy Skin Disease",
            "Blackleg",
            "Anthrax",
            "Pneumonia",
            "Healthy",
            "Mange",
            "Ringworm",
            "Bloat"
        };
        
        if (classIndex >= 0 && classIndex < diseaseNames.length) {
            return diseaseNames[classIndex];
        }
        
        return "Unknown Disease";
    }
    
    private String getDiseaseSeverity(String diseaseName) {
        // Return severity based on disease name
        switch (diseaseName.toLowerCase()) {
            case "anthrax":
            case "blackleg":
                return "Critical";
            case "foot and mouth disease":
            case "lumpy skin disease":
                return "High";
            case "mastitis":
            case "pneumonia":
                return "Medium";
            case "mange":
            case "ringworm":
            case "bloat":
                return "Low";
            case "healthy":
                return "None";
            default:
                return "Unknown";
        }
    }
    
    private String getDiseaseSymptoms(String diseaseName) {
        // Return symptoms based on disease name
        switch (diseaseName.toLowerCase()) {
            case "foot and mouth disease":
                return "Fever, blisters in mouth and feet, lameness, excessive salivation";
            case "mastitis":
                return "Swollen udder, abnormal milk, fever, loss of appetite";
            case "lumpy skin disease":
                return "Firm nodules on skin, fever, reduced milk production";
            case "blackleg":
                return "Sudden death, lameness, swelling in muscles, fever";
            case "anthrax":
                return "Sudden death, bleeding from body openings, high fever";
            case "pneumonia":
                return "Coughing, difficulty breathing, fever, nasal discharge";
            case "mange":
                return "Itching, hair loss, skin thickening, restlessness";
            case "ringworm":
                return "Circular lesions, hair loss, scaly skin";
            case "bloat":
                return "Distended abdomen, difficulty breathing, restlessness";
            case "healthy":
                return "No symptoms observed";
            default:
                return "Symptoms vary";
        }
    }
    
    private String getDiseaseTreatment(String diseaseName) {
        // Return treatment recommendations
        switch (diseaseName.toLowerCase()) {
            case "foot and mouth disease":
                return "Vaccination, isolation, supportive care, antibiotic treatment for secondary infections";
            case "mastitis":
                return "Antibiotic treatment, anti-inflammatory drugs, milking hygiene";
            case "lumpy skin disease":
                return "Supportive care, antibiotic treatment, vaccination";
            case "blackleg":
                return "Emergency vaccination, antibiotic treatment, surgical drainage";
            case "anthrax":
                return "Immediate veterinary attention, antibiotic treatment, isolation";
            case "pneumonia":
                return "Antibiotic treatment, anti-inflammatory drugs, good ventilation";
            case "mange":
                return "Acaricide treatment, environmental cleaning, isolation";
            case "ringworm":
                return "Antifungal treatment, topical medication, environmental cleaning";
            case "bloat":
                return "Emergency treatment, stomach tube, anti-foaming agents";
            case "healthy":
                return "Continue regular health monitoring";
            default:
                return "Consult veterinarian for treatment";
        }
    }
    
    private String getDiseasePrevention(String diseaseName) {
        // Return prevention measures
        switch (diseaseName.toLowerCase()) {
            case "foot and mouth disease":
                return "Vaccination, biosecurity measures, avoid contact with infected animals";
            case "mastitis":
                return "Proper milking hygiene, clean bedding, regular udder health checks";
            case "lumpy skin disease":
                return "Vaccination, vector control, quarantine new animals";
            case "blackleg":
                return "Vaccination, avoid deep wounds, proper wound care";
            case "anthrax":
                return "Vaccination, avoid contaminated areas, proper carcass disposal";
            case "pneumonia":
                return "Good ventilation, proper nutrition, stress reduction, vaccination";
            case "mange":
                return "Regular health checks, quarantine new animals, clean environment";
            case "ringworm":
                return "Good hygiene, avoid contact with infected animals, clean environment";
            case "bloat":
                return "Proper feeding management, avoid sudden diet changes, monitor grazing";
            case "healthy":
                return "Continue current health management practices";
            default:
                return "Maintain good biosecurity and health management";
        }
    }
    
    private boolean isDiseaseContagious(String diseaseName) {
        // Return whether disease is contagious
        switch (diseaseName.toLowerCase()) {
            case "foot and mouth disease":
            case "lumpy skin disease":
            case "anthrax":
            case "pneumonia":
            case "mange":
            case "ringworm":
                return true;
            case "mastitis":
            case "blackleg":
            case "bloat":
            case "healthy":
                return false;
            default:
                return false;
        }
    }
    
    private String getAffectedBodyParts(String diseaseName) {
        // Return affected body parts
        switch (diseaseName.toLowerCase()) {
            case "foot and mouth disease":
                return "Mouth, feet, udder";
            case "mastitis":
                return "Udder, mammary glands";
            case "lumpy skin disease":
                return "Skin, lymph nodes";
            case "blackleg":
                return "Muscles, particularly legs";
            case "anthrax":
                return "Multiple organs, blood";
            case "pneumonia":
                return "Lungs, respiratory system";
            case "mange":
                return "Skin, hair follicles";
            case "ringworm":
                return "Skin, hair";
            case "bloat":
                return "Stomach, digestive system";
            case "healthy":
                return "None";
            default:
                return "Various";
        }
    }
    
    public void close() {
        if (interpreter != null) {
            interpreter.close();
            interpreter = null;
        }
    }
}
