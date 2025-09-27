package com.mifugocare.app.database.dao;

import androidx.room.Dao;
import androidx.room.Delete;
import androidx.room.Insert;
import androidx.room.Query;
import androidx.room.Update;

import com.mifugocare.app.database.entities.Livestock;

import java.util.List;

@Dao
public interface LivestockDao {
    
    @Query("SELECT * FROM livestock WHERE farmerId = :farmerId ORDER BY lastUpdated DESC")
    List<Livestock> getLivestockByFarmer(int farmerId);
    
    @Query("SELECT * FROM livestock WHERE livestockId = :livestockId")
    Livestock getLivestockById(int livestockId);
    
    @Query("SELECT * FROM livestock WHERE species = :species AND farmerId = :farmerId")
    List<Livestock> getLivestockBySpecies(String species, int farmerId);
    
    @Query("SELECT * FROM livestock WHERE healthStatus = :status AND farmerId = :farmerId")
    List<Livestock> getLivestockByHealthStatus(String status, int farmerId);
    
    @Query("SELECT * FROM livestock WHERE tagNumber = :tagNumber AND farmerId = :farmerId")
    Livestock getLivestockByTagNumber(String tagNumber, int farmerId);
    
    @Query("SELECT COUNT(*) FROM livestock WHERE farmerId = :farmerId")
    int getLivestockCount(int farmerId);
    
    @Query("SELECT COUNT(*) FROM livestock WHERE species = :species AND farmerId = :farmerId")
    int getLivestockCountBySpecies(String species, int farmerId);
    
    @Query("SELECT * FROM livestock WHERE farmerId = :farmerId AND " +
           "(species LIKE '%' || :searchQuery || '%' OR " +
           "breed LIKE '%' || :searchQuery || '%' OR " +
           "tagNumber LIKE '%' || :searchQuery || '%')")
    List<Livestock> searchLivestock(int farmerId, String searchQuery);
    
    @Insert
    long insertLivestock(Livestock livestock);
    
    @Insert
    List<Long> insertLivestockList(List<Livestock> livestockList);
    
    @Update
    void updateLivestock(Livestock livestock);
    
    @Delete
    void deleteLivestock(Livestock livestock);
    
    @Query("DELETE FROM livestock WHERE livestockId = :livestockId")
    void deleteLivestockById(int livestockId);
    
    @Query("DELETE FROM livestock WHERE farmerId = :farmerId")
    void deleteLivestockByFarmer(int farmerId);
}
