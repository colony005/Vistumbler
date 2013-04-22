package com.eiri.wifidb_uploader;

import java.util.List;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Location;
import android.net.wifi.ScanResult;
import android.preference.PreferenceManager;
import android.util.Log;


public class WiFiScanReceiver extends BroadcastReceiver {
  private static final String TAG = "WiFiDB_WiFiScanReceiver";
  ScanService ScanService;

  public WiFiScanReceiver(ScanService ScanService) {
    super();
    this.ScanService = ScanService;
  }

  @Override
  public void onReceive(Context c, Intent intent) {
	  
    List<ScanResult> results = ScanService.wifi.getScanResults();

    for (final ScanResult result : results) {
    	
    	Log.d(TAG, "onReceive() get gps");
	    
	    MyLocation my_location = new MyLocation();
		my_location.init(c, null);	    
	    
		Location location = MyLocation.getLocation(c);
	    final Double latitude = location.getLatitude();
	    final Double longitude = location.getLongitude();
	    Integer sats = MyLocation.getGpsStatus(c);
	    
	    SharedPreferences sharedPrefs = PreferenceManager.getDefaultSharedPreferences(c);
	    final String WifiDb_ApiURL = sharedPrefs.getString("wifidb_upload_api_url", "https://api.wifidb.net/");
	    String WifiDb_Username = sharedPrefs.getString("wifidb_username", "Anonymous"); 
	    String WifiDb_ApiKey = sharedPrefs.getString("wifidb_upload_api_url", ""); 
    	
	    Log.d(TAG, "LAT: " + latitude + "LONG: " + longitude + "SATS: " + sats);
	    final String Label = "";
	    
	    new Thread(new Runnable() {
	        public void run() {
	        	Log.d(TAG, "onReceive() http post");
	        	WifiDB post = new WifiDB();
	        	post.postLiveData(WifiDb_ApiURL, result.SSID, result.BSSID, result.capabilities, result.frequency, result.level, latitude, longitude, Label);
	        }
	      }).start();	    
    }

  }

public static String getTag() {
	return TAG;
}
}