using Toybox.Application;
using AntAssetTracker;
using Toybox.Timer;
using Toybox.Position;

class DogTrackerApp extends Application.AppBase {
    var sensor;
    var commTimer;
    var beacon;
    var locationHistory;

    function initialize() {
        AppBase.initialize();
        if(getProperty("beaconUrl").length() > 4) {
        	beacon = new Beacon(getProperty("beaconUrl"));
        }
        locationHistory = {};
    }

    function onStart(state) {
        try {
            //Create the sensor object and open it
            sensor = new AntAssetTracker.TrackerSensor();
            sensor.open();
            System.println("sensor open");
            
            commTimer = new Timer.Timer();
    		commTimer.start(method(:timerCallback), 10000, true);
        } catch(e instanceof Ant.UnableToAcquireChannelException) {
            System.println(e.getErrorMessage());
            sensor = null;
            System.println("got exception");
        }
    }

    function getInitialView() {
        return [new ConnectingView()];
    }

    function onStop(state) {
        sensor.closeSensor();
        commTimer.stop();
        return false;
    }
    
    function timerCallback() {
    	if(sensor != null && sensor.searching == false) {
    		sendDogData();
    		updateLocationHistory();
		}
    }
    function sendDogData() {
    	var params = {:dogdata=>sensor.assets.getAssets()};
    	if(beacon) {
			beacon.sendAssetData(sensor.assets.getAssets());
			System.println("Beacon data sent");	
		}
    }
    function updateLocationHistory() {
    	var assets = sensor.assets.getAssets();
    	for(var i = 0; i < assets.size(); i++){
    		var aIdx = assets[i].index;
        	if(!locationHistory.hasKey(aIdx)) {
        		locationHistory[aIdx] = [];
        	}
        	locationHistory[aIdx].add(new Position.Location({:latitude => assets[i].latitude, :longitude =>assets[i].longitude, :format => :degrees}));
        	if(locationHistory[aIdx].size() > 40) {
        		locationHistory[aIdx] = locationHistory[aIdx].slice(-40,null);
        	}
        }
    }
    function getLocationHistory() {
    	return locationHistory;
    }
    function onSettingsChanged() {
    	System.println("settings changed");
    	
    	if(getProperty("beaconUrl").length() > 4) {
        	beacon = new Beacon(getProperty("beaconUrl"));
        	System.println("Beacon configured *" +getProperty("beaconUrl") + "*");
        } else {
        	beacon = null;
        	System.println("Beacon disabled");
    	}
    }
}
