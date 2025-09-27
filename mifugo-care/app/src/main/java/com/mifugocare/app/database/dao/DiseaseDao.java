package com.mifugocare.app.database.dao;

import androidx.room.Dao;
import androidx.room.Delete;
import androidx.room.Insert;
import androidx.room.Query;
import androidx.room.Update;

import com.mifugocare.app.database.entities.Disease;

import java.util.List;

@Dao
public interface DiseaseDao {
    
    @Query("SELECT * FROM diseases ORDER BY diseaseName ASC")
    List<Disease> getAllDiseases();
    
    @Query("SELECT * FROM diseases WHERE diseaseId = :diseaseId")
    Disease getDiseaseById(int diseaseId);
    
    @Query("SELECT * FROM diseases WHERE diseaseName = :diseaseName")
    Disease getDiseaseByName(String diseaseName);
    
    @Query("SELECT * FROM diseases WHERE species = :species")
    List<Disease> getDiseasesBySpecies(String species);
    
    @Query("SELECT * FROM diseases WHERE severity = :severity")
    List<Disease> getDiseasesBySeverity(String severity);
    
    @Query("SELECT * FROM diseases WHERE contagious = :contagious")
    List<Disease> getDiseasesByContagious(String contagious);
    
    @Query("SELECT * FROM diseases WHERE " +
           "(diseaseName LIKE '%' || :searchQuery || '%' OR " +
           "scientificName LIKE '%' || :searchQuery || '%' OR " +
           "symptoms LIKE '%' || :searchQuery || '%')")
    List<Disease> searchDiseases(String searchQuery);
    
    @Query("SELECT * FROM diseases WHERE species = :species AND " +
           "(diseaseName LIKE '%' || :searchQuery || '%' OR " +
           "symptoms LIKE '%' || :searchQuery || '%')")
    List<Disease> searchDiseasesBySpecies(String species, String searchQuery);
    
    @Query("SELECT * FROM diseases WHERE diseaseName IN (:diseaseNames)")
    List<Disease> getDiseasesByNames(List<String> diseaseNames);
    
    @Query("SELECT COUNT(*) FROM diseases")
    int getDiseaseCount();
    
    @Query("SELECT COUNT(*) FROM diseases WHERE species = :species")
    int getDiseaseCountBySpecies(String species);
    
    @Insert
    long insertDisease(Disease disease);
    
    @Insert
    List<Long> insertDiseaseList(List<Disease> diseaseList);
    
    @Update
    void updateDisease(Disease disease);
    
    @Delete
    void deleteDisease(Disease disease);
    
    @Query("DELETE FROM diseases WHERE diseaseId = :diseaseId")
    void deleteDiseaseById(int diseaseId);
    
    @Query("DELETE FROM diseases")
    void deleteAllDiseases();
}
