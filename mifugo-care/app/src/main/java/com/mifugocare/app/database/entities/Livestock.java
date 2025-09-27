package com.mifugocare.app.database.entities;

import androidx.room.Entity;
import androidx.room.PrimaryKey;
import androidx.room.ForeignKey;

@Entity(tableName = "livestock",
        foreignKeys = @ForeignKey(entity = Farmer.class,
                parentColumns = "farmerId",
                childColumns = "farmerId",
                onDelete = ForeignKey.CASCADE))
public class Livestock {
    @PrimaryKey(autoGenerate = true)
    public int livestockId;
    
    public int farmerId;
    public String species; // e.g., "Cow", "Goat", "Sheep"
    public String breed;
    public String age;
    public String weight;
    public String gender;
    public String tagNumber;
    public String healthStatus;
    public String location;
    public String notes;
    public long dateAdded;
    public long lastUpdated;
    
    // Constructors
    public Livestock() {
        this.dateAdded = System.currentTimeMillis();
        this.lastUpdated = System.currentTimeMillis();
    }
    
    public Livestock(int farmerId, String species, String breed, String age, 
                    String weight, String gender, String tagNumber) {
        this();
        this.farmerId = farmerId;
        this.species = species;
        this.breed = breed;
        this.age = age;
        this.weight = weight;
        this.gender = gender;
        this.tagNumber = tagNumber;
        this.healthStatus = "Healthy";
    }
    
    // Getters and Setters
    public int getLivestockId() { return livestockId; }
    public void setLivestockId(int livestockId) { this.livestockId = livestockId; }
    
    public int getFarmerId() { return farmerId; }
    public void setFarmerId(int farmerId) { this.farmerId = farmerId; }
    
    public String getSpecies() { return species; }
    public void setSpecies(String species) { this.species = species; }
    
    public String getBreed() { return breed; }
    public void setBreed(String breed) { this.breed = breed; }
    
    public String getAge() { return age; }
    public void setAge(String age) { this.age = age; }
    
    public String getWeight() { return weight; }
    public void setWeight(String weight) { this.weight = weight; }
    
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    
    public String getTagNumber() { return tagNumber; }
    public void setTagNumber(String tagNumber) { this.tagNumber = tagNumber; }
    
    public String getHealthStatus() { return healthStatus; }
    public void setHealthStatus(String healthStatus) { this.healthStatus = healthStatus; }
    
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    
    public long getDateAdded() { return dateAdded; }
    public void setDateAdded(long dateAdded) { this.dateAdded = dateAdded; }
    
    public long getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(long lastUpdated) { this.lastUpdated = lastUpdated; }
}
