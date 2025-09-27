package com.mifugocare.app;

import android.app.Application;

import com.mifugocare.app.database.AppDatabase;
import com.mifugocare.app.utils.DatabaseUtils;

public class MifugoCareApplication extends Application {
    
    private static MifugoCareApplication instance;
    private AppDatabase database;
    
    @Override
    public void onCreate() {
        super.onCreate();
        instance = this;
        
        // Initialize database
        database = AppDatabase.getDatabase(this);
        
        // Initialize sample data on first launch
        initializeApp();
    }
    
    private void initializeApp() {
        // Initialize sample data if this is the first launch
        DatabaseUtils.initializeSampleData(this);
    }
    
    public static MifugoCareApplication getInstance() {
        return instance;
    }
    
    public AppDatabase getDatabase() {
        return database;
    }
    
    @Override
    public void onTerminate() {
        super.onTerminate();
        if (database != null) {
            AppDatabase.destroyInstance();
        }
    }
}
