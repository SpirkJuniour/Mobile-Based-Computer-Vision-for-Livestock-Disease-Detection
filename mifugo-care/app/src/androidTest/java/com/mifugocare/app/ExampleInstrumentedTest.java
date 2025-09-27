package com.mifugocare.app;

import android.content.Context;

import androidx.test.platform.app.InstrumentationRegistry;
import androidx.test.ext.junit.runners.AndroidJUnit4;

import org.junit.Test;
import org.junit.runner.RunWith;

import static org.junit.Assert.*;

/**
 * Instrumented test, which will execute on an Android device.
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
@RunWith(AndroidJUnit4.class)
public class ExampleInstrumentedTest {
    @Test
    public void useAppContext() {
        // Context of the app under test.
        Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
        assertEquals("com.mifugocare.app", appContext.getPackageName());
    }
    
    @Test
    public void testAppContextNotNull() {
        Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
        assertNotNull("App context should not be null", appContext);
    }
    
    @Test
    public void testAppContextPackageName() {
        Context appContext = InstrumentationRegistry.getInstrumentation().getTargetContext();
        String packageName = appContext.getPackageName();
        assertNotNull("Package name should not be null", packageName);
        assertTrue("Package name should contain 'mifugocare'", packageName.contains("mifugocare"));
    }
}
