package com.mifugocare.app.database;

import android.content.Context;

import androidx.room.Database;
import androidx.room.Room;
import androidx.room.RoomDatabase;
import androidx.room.TypeConverters;

import com.mifugocare.app.database.dao.DiagnosisDao;
import com.mifugocare.app.database.dao.DiseaseDao;
import com.mifugocare.app.database.dao.LivestockDao;
import com.mifugocare.app.database.entities.Diagnosis;
import com.mifugocare.app.database.entities.Disease;
import com.mifugocare.app.database.entities.Farmer;
import com.mifugocare.app.database.entities.Livestock;

@Database(
    entities = {
        Farmer.class,
        Livestock.class,
        Disease.class,
        Diagnosis.class
    },
    version = 1,
    exportSchema = false
)
@TypeConverters({})
public abstract class AppDatabase extends RoomDatabase {
    
    private static final String DATABASE_NAME = "mifugo_care_database";
    private static volatile AppDatabase INSTANCE;
    
    public abstract LivestockDao livestockDao();
    public abstract DiseaseDao diseaseDao();
    public abstract DiagnosisDao diagnosisDao();
    
    public static AppDatabase getDatabase(Context context) {
        if (INSTANCE == null) {
            synchronized (AppDatabase.class) {
                if (INSTANCE == null) {
                    INSTANCE = Room.databaseBuilder(
                        context.getApplicationContext(),
                        AppDatabase.class,
                        DATABASE_NAME
                    )
                    .fallbackToDestructiveMigration()
                    .build();
                }
            }
        }
        return INSTANCE;
    }
    
    public static void destroyInstance() {
        INSTANCE = null;
    }
}
