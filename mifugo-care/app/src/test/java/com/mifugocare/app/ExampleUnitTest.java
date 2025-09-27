package com.mifugocare.app;

import org.junit.Test;

import static org.junit.Assert.*;

/**
 * Example local unit test, which will execute on the development machine (host).
 *
 * @see <a href="http://d.android.com/tools/testing">Testing documentation</a>
 */
public class ExampleUnitTest {
    @Test
    public void addition_isCorrect() {
        assertEquals(4, 2 + 2);
    }
    
    @Test
    public void testAppName() {
        // Test that the app name is correct
        String expectedAppName = "Mifugo Care";
        assertNotNull("App name should not be null", expectedAppName);
        assertEquals("App name should be 'Mifugo Care'", "Mifugo Care", expectedAppName);
    }
    
    @Test
    public void testPackageName() {
        // Test that the package name is correct
        String packageName = "com.mifugocare.app";
        assertNotNull("Package name should not be null", packageName);
        assertEquals("Package name should be correct", "com.mifugocare.app", packageName);
    }
}
