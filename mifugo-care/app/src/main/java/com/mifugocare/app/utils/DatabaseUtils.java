package com.mifugocare.app.utils;

import android.content.Context;

import com.mifugocare.app.database.AppDatabase;
import com.mifugocare.app.database.entities.Disease;
import com.mifugocare.app.database.entities.Farmer;
import com.mifugocare.app.database.entities.Livestock;

import java.util.ArrayList;
import java.util.List;

public class DatabaseUtils {
    
    /**
     * Initialize database with sample data
     */
    public static void initializeSampleData(Context context) {
        AppDatabase database = AppDatabase.getDatabase(context);
        
        // Add sample farmer
        addSampleFarmer(database);
        
        // Add sample diseases
        addSampleDiseases(database);
        
        // Add sample livestock
        addSampleLivestock(database);
    }
    
    private static void addSampleFarmer(AppDatabase database) {
        Farmer farmer = new Farmer();
        farmer.setFirstName("John");
        farmer.setLastName("Mwangi");
        farmer.setEmail("john.mwangi@example.com");
        farmer.setPhoneNumber("+254712345678");
        farmer.setFarmName("Mwangi Farm");
        farmer.setFarmLocation("Nakuru, Kenya");
        farmer.setFarmSize("50 acres");
        farmer.setLivestockCount("150");
        farmer.setExperience("10 years");
        farmer.setSpecialization("Dairy");
        farmer.setPreferredLanguage("English");
        
        // Insert farmer (this would normally be done through DAO)
        // database.farmerDao().insertFarmer(farmer);
    }
    
    private static void addSampleDiseases(AppDatabase database) {
        List<Disease> diseases = new ArrayList<>();
        
        // Foot and Mouth Disease
        Disease fmd = new Disease();
        fmd.setDiseaseName("Foot and Mouth Disease");
        fmd.setScientificName("Aphthae epizooticae");
        fmd.setSpecies("Cattle, Sheep, Goats");
        fmd.setSymptoms("Fever, blisters in mouth and feet, lameness, excessive salivation, loss of appetite");
        fmd.setCauses("Virus transmission through contact, contaminated feed/water");
        fmd.setPrevention("Vaccination, biosecurity measures, quarantine new animals");
        fmd.setTreatment("Supportive care, antibiotic treatment for secondary infections, isolation");
        fmd.setSeverity("High");
        fmd.setContagious("Yes");
        fmd.setMortalityRate("Low (1-5%)");
        fmd.setAffectedBodyParts("Mouth, feet, udder");
        fmd.setSeasonality("All year, peaks in dry season");
        diseases.add(fmd);
        
        // Mastitis
        Disease mastitis = new Disease();
        mastitis.setDiseaseName("Mastitis");
        mastitis.setScientificName("Mammary gland inflammation");
        mastitis.setSpecies("Cattle");
        mastitis.setSymptoms("Swollen udder, abnormal milk (clots, blood), fever, loss of appetite");
        mastitis.setCauses("Bacterial infection, poor milking hygiene, stress");
        mastitis.setPrevention("Proper milking hygiene, clean bedding, regular udder health checks");
        mastitis.setTreatment("Antibiotic treatment, anti-inflammatory drugs, milking hygiene");
        mastitis.setSeverity("Medium");
        mastitis.setContagious("No");
        mastitis.setMortalityRate("Very low");
        mastitis.setAffectedBodyParts("Udder, mammary glands");
        mastitis.setSeasonality("All year");
        diseases.add(mastitis);
        
        // Lumpy Skin Disease
        Disease lsd = new Disease();
        lsd.setDiseaseName("Lumpy Skin Disease");
        lsd.setScientificName("Neethling virus infection");
        lsd.setSpecies("Cattle");
        lsd.setSymptoms("Firm nodules on skin, fever, reduced milk production, loss of appetite");
        lsd.setCauses("Virus transmission by insects, contact with infected animals");
        lsd.setPrevention("Vaccination, vector control, quarantine new animals");
        lsd.setTreatment("Supportive care, antibiotic treatment for secondary infections");
        lsd.setSeverity("High");
        lsd.setContagious("Yes");
        lsd.setMortalityRate("Low (1-5%)");
        lsd.setAffectedBodyParts("Skin, lymph nodes");
        lsd.setSeasonality("Peaks in rainy season");
        diseases.add(lsd);
        
        // Blackleg
        Disease blackleg = new Disease();
        blackleg.setDiseaseName("Blackleg");
        blackleg.setScientificName("Clostridium chauvoei infection");
        blackleg.setSpecies("Cattle, Sheep");
        blackleg.setSymptoms("Sudden death, lameness, swelling in muscles, fever, depression");
        blackleg.setCauses("Bacterial spores in soil, wounds, deep muscle injuries");
        blackleg.setPrevention("Vaccination, avoid deep wounds, proper wound care");
        blackleg.setTreatment("Emergency vaccination, antibiotic treatment, surgical drainage");
        blackleg.setSeverity("Critical");
        blackleg.setContagious("No");
        blackleg.setMortalityRate("High (80-100%)");
        blackleg.setAffectedBodyParts("Muscles, particularly legs");
        blackleg.setSeasonality("All year, peaks in wet season");
        diseases.add(blackleg);
        
        // Anthrax
        Disease anthrax = new Disease();
        anthrax.setDiseaseName("Anthrax");
        anthrax.setScientificName("Bacillus anthracis infection");
        anthrax.setSpecies("Cattle, Sheep, Goats");
        anthrax.setSymptoms("Sudden death, bleeding from body openings, high fever, difficulty breathing");
        anthrax.setCauses("Bacterial spores in soil, contaminated feed/water");
        anthrax.setPrevention("Vaccination, avoid contaminated areas, proper carcass disposal");
        anthrax.setTreatment("Immediate veterinary attention, antibiotic treatment, isolation");
        anthrax.setSeverity("Critical");
        anthrax.setContagious("Yes");
        anthrax.setMortalityRate("High (90-100%)");
        anthrax.setAffectedBodyParts("Multiple organs, blood");
        anthrax.setSeasonality("All year, peaks in dry season");
        diseases.add(anthrax);
        
        // Insert diseases
        database.diseaseDao().insertDiseaseList(diseases);
    }
    
    private static void addSampleLivestock(AppDatabase database) {
        List<Livestock> livestockList = new ArrayList<>();
        
        // Sample cattle
        for (int i = 1; i <= 10; i++) {
            Livestock cattle = new Livestock();
            cattle.setFarmerId(1); // Assuming farmer ID 1
            cattle.setSpecies("Cattle");
            cattle.setBreed("Friesian");
            cattle.setAge(i + " years");
            cattle.setWeight((400 + i * 10) + " kg");
            cattle.setGender(i % 2 == 0 ? "Female" : "Male");
            cattle.setTagNumber("F" + String.format("%03d", i));
            cattle.setHealthStatus("Healthy");
            cattle.setLocation("Paddock A");
            livestockList.add(cattle);
        }
        
        // Sample goats
        for (int i = 1; i <= 5; i++) {
            Livestock goat = new Livestock();
            goat.setFarmerId(1);
            goat.setSpecies("Goat");
            goat.setBreed("Boer");
            goat.setAge(i + " years");
            goat.setWeight((50 + i * 5) + " kg");
            goat.setGender(i % 2 == 0 ? "Female" : "Male");
            goat.setTagNumber("G" + String.format("%03d", i));
            goat.setHealthStatus("Healthy");
            goat.setLocation("Paddock B");
            livestockList.add(goat);
        }
        
        // Insert livestock
        database.livestockDao().insertLivestockList(livestockList);
    }
    
    /**
     * Clear all data from database
     */
    public static void clearAllData(Context context) {
        AppDatabase database = AppDatabase.getDatabase(context);
        
        // Clear all tables (this would be done through DAOs)
        // database.diagnosisDao().deleteAllDiagnoses();
        // database.livestockDao().deleteAllLivestock();
        // database.diseaseDao().deleteAllDiseases();
        // database.farmerDao().deleteAllFarmers();
    }
    
    /**
     * Get database statistics
     */
    public static DatabaseStats getDatabaseStats(Context context) {
        AppDatabase database = AppDatabase.getDatabase(context);
        
        DatabaseStats stats = new DatabaseStats();
        stats.totalFarmers = 1; // database.farmerDao().getFarmerCount();
        stats.totalLivestock = database.livestockDao().getLivestockCount(1);
        stats.totalDiseases = database.diseaseDao().getDiseaseCount();
        stats.totalDiagnoses = database.diagnosisDao().getDiagnosisCount();
        
        return stats;
    }
    
    public static class DatabaseStats {
        public int totalFarmers;
        public int totalLivestock;
        public int totalDiseases;
        public int totalDiagnoses;
    }
}
