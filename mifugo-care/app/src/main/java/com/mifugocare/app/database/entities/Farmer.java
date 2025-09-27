package com.mifugocare.app.database.entities;

import androidx.room.Entity;
import androidx.room.PrimaryKey;

@Entity(tableName = "farmers")
public class Farmer {
    @PrimaryKey(autoGenerate = true)
    public int farmerId;
    
    public String firstName;
    public String lastName;
    public String email;
    public String phoneNumber;
    public String farmName;
    public String farmLocation;
    public String farmSize;
    public String livestockCount;
    public String experience;
    public String specialization; // e.g., "Dairy", "Beef", "Mixed"
    public String preferredLanguage;
    public String profileImagePath;
    public boolean isActive;
    public long registrationDate;
    public long lastLoginDate;
    public long lastUpdated;
    
    // Constructors
    public Farmer() {
        this.registrationDate = System.currentTimeMillis();
        this.lastUpdated = System.currentTimeMillis();
        this.isActive = true;
    }
    
    public Farmer(String firstName, String lastName, String email, 
                 String phoneNumber, String farmName, String farmLocation) {
        this();
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.phoneNumber = phoneNumber;
        this.farmName = farmName;
        this.farmLocation = farmLocation;
    }
    
    // Getters and Setters
    public int getFarmerId() { return farmerId; }
    public void setFarmerId(int farmerId) { this.farmerId = farmerId; }
    
    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }
    
    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }
    
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    
    public String getPhoneNumber() { return phoneNumber; }
    public void setPhoneNumber(String phoneNumber) { this.phoneNumber = phoneNumber; }
    
    public String getFarmName() { return farmName; }
    public void setFarmName(String farmName) { this.farmName = farmName; }
    
    public String getFarmLocation() { return farmLocation; }
    public void setFarmLocation(String farmLocation) { this.farmLocation = farmLocation; }
    
    public String getFarmSize() { return farmSize; }
    public void setFarmSize(String farmSize) { this.farmSize = farmSize; }
    
    public String getLivestockCount() { return livestockCount; }
    public void setLivestockCount(String livestockCount) { this.livestockCount = livestockCount; }
    
    public String getExperience() { return experience; }
    public void setExperience(String experience) { this.experience = experience; }
    
    public String getSpecialization() { return specialization; }
    public void setSpecialization(String specialization) { this.specialization = specialization; }
    
    public String getPreferredLanguage() { return preferredLanguage; }
    public void setPreferredLanguage(String preferredLanguage) { this.preferredLanguage = preferredLanguage; }
    
    public String getProfileImagePath() { return profileImagePath; }
    public void setProfileImagePath(String profileImagePath) { this.profileImagePath = profileImagePath; }
    
    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }
    
    public long getRegistrationDate() { return registrationDate; }
    public void setRegistrationDate(long registrationDate) { this.registrationDate = registrationDate; }
    
    public long getLastLoginDate() { return lastLoginDate; }
    public void setLastLoginDate(long lastLoginDate) { this.lastLoginDate = lastLoginDate; }
    
    public long getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(long lastUpdated) { this.lastUpdated = lastUpdated; }
    
    // Helper methods
    public String getFullName() {
        return firstName + " " + lastName;
    }
}
