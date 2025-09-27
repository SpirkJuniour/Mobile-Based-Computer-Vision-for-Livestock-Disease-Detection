package com.mifugocare.app.database.dao;

import androidx.room.Dao;
import androidx.room.Delete;
import androidx.room.Insert;
import androidx.room.Query;
import androidx.room.Update;

import com.mifugocare.app.database.entities.Diagnosis;

import java.util.List;

@Dao
public interface DiagnosisDao {
    
    @Query("SELECT * FROM diagnoses ORDER BY diagnosisDate DESC")
    List<Diagnosis> getAllDiagnoses();
    
    @Query("SELECT * FROM diagnoses WHERE diagnosisId = :diagnosisId")
    Diagnosis getDiagnosisById(int diagnosisId);
    
    @Query("SELECT * FROM diagnoses WHERE livestockId = :livestockId ORDER BY diagnosisDate DESC")
    List<Diagnosis> getDiagnosesByLivestock(int livestockId);
    
    @Query("SELECT * FROM diagnoses WHERE diseaseId = :diseaseId ORDER BY diagnosisDate DESC")
    List<Diagnosis> getDiagnosesByDisease(int diseaseId);
    
    @Query("SELECT * FROM diagnoses WHERE status = :status ORDER BY diagnosisDate DESC")
    List<Diagnosis> getDiagnosesByStatus(String status);
    
    @Query("SELECT * FROM diagnoses WHERE confidence >= :minConfidence ORDER BY diagnosisDate DESC")
    List<Diagnosis> getDiagnosesByConfidence(float minConfidence);
    
    @Query("SELECT * FROM diagnoses WHERE diagnosisDate >= :startDate AND diagnosisDate <= :endDate ORDER BY diagnosisDate DESC")
    List<Diagnosis> getDiagnosesByDateRange(long startDate, long endDate);
    
    @Query("SELECT * FROM diagnoses WHERE isTreated = :isTreated ORDER BY diagnosisDate DESC")
    List<Diagnosis> getDiagnosesByTreatmentStatus(boolean isTreated);
    
    @Query("SELECT * FROM diagnoses WHERE livestockId IN " +
           "(SELECT livestockId FROM livestock WHERE farmerId = :farmerId) " +
           "ORDER BY diagnosisDate DESC")
    List<Diagnosis> getDiagnosesByFarmer(int farmerId);
    
    @Query("SELECT * FROM diagnoses WHERE livestockId IN " +
           "(SELECT livestockId FROM livestock WHERE farmerId = :farmerId AND species = :species) " +
           "ORDER BY diagnosisDate DESC")
    List<Diagnosis> getDiagnosesByFarmerAndSpecies(int farmerId, String species);
    
    @Query("SELECT * FROM diagnoses WHERE " +
           "(diagnosisResult LIKE '%' || :searchQuery || '%' OR " +
           "notes LIKE '%' || :searchQuery || '%' OR " +
           "veterinarianNotes LIKE '%' || :searchQuery || '%') " +
           "ORDER BY diagnosisDate DESC")
    List<Diagnosis> searchDiagnoses(String searchQuery);
    
    @Query("SELECT COUNT(*) FROM diagnoses")
    int getDiagnosisCount();
    
    @Query("SELECT COUNT(*) FROM diagnoses WHERE livestockId = :livestockId")
    int getDiagnosisCountByLivestock(int livestockId);
    
    @Query("SELECT COUNT(*) FROM diagnoses WHERE status = :status")
    int getDiagnosisCountByStatus(String status);
    
    @Query("SELECT AVG(confidence) FROM diagnoses WHERE livestockId = :livestockId")
    float getAverageConfidenceByLivestock(int livestockId);
    
    @Query("SELECT * FROM diagnoses WHERE livestockId = :livestockId ORDER BY diagnosisDate DESC LIMIT 1")
    Diagnosis getLatestDiagnosisByLivestock(int livestockId);
    
    @Insert
    long insertDiagnosis(Diagnosis diagnosis);
    
    @Insert
    List<Long> insertDiagnosisList(List<Diagnosis> diagnosisList);
    
    @Update
    void updateDiagnosis(Diagnosis diagnosis);
    
    @Delete
    void deleteDiagnosis(Diagnosis diagnosis);
    
    @Query("DELETE FROM diagnoses WHERE diagnosisId = :diagnosisId")
    void deleteDiagnosisById(int diagnosisId);
    
    @Query("DELETE FROM diagnoses WHERE livestockId = :livestockId")
    void deleteDiagnosesByLivestock(int livestockId);
}
