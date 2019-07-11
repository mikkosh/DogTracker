using Toybox.WatchUi;
using Toybox.Position;
using Toybox.Timer;
using Toybox.Graphics;

class DogMapView extends WatchUi.MapView {
	
	var timer;
	var assetIndex;
	
    // Initialize the MapView
    function initialize(pAssetIndex) {
        MapView.initialize();
        
        assetIndex = pAssetIndex;
        
		var ownPosition = getOwnPosition().toDegrees();
		var diff = 0.004;
        // Set the top left and bottom right Location object for the Map Visible Area
        var top_left = new Position.Location({:latitude => ownPosition[0]+diff, :longitude =>ownPosition[1]-diff, :format => :degrees});
        var bottom_right = new Position.Location({:latitude => ownPosition[0]-diff, :longitude =>ownPosition[1]+diff, :format => :degrees});
       	MapView.setMapVisibleArea(top_left, bottom_right);
        
        // Set the area in which to display the selected map area
        MapView.setScreenVisibleArea(0, 0, 240, 240/2);
        // Set the map mode
        MapView.setMapMode(WatchUi.MAP_MODE_PREVIEW);
        //updateMapData();
    }
    function onShow() {
       	timer = new Timer.Timer();
    	timer.start(method(:updateMapData), 1000, true);
    	//updateMapData();
    	MapView.onShow();
    }
	function onHide() {
       timer.stop();
       MapView.onHide();
    }
    
    function updateMapData() {
	    
        var lhist = Application.getApp().getLocationHistory();
        var assets = Application.getApp().sensor.assets.getAssets();
        
        
        var tlat = null;
        var tlon = null;
        var blat = null;
        var blon = null;
        
        var pl = new WatchUi.MapPolyline();
		
		pl.setWidth(5);
		
		// if index cannot be found in asset array
		if(assetIndex >= assets.size()) {
			WatchUi.popView(WatchUi.SLIDE_UP);
			System.println("assetIndex >= assets.size()");
			return;
		}
        var asset = assets[assetIndex];
        // put the locations to the polyline, check if we have history data available
        if(lhist.hasKey(asset.index)) {
        	System.println("lhist.hasKey(asset.index)");
        	pl.setColor(getColor(asset.color)); // this generates out of bounds errors if a tracker disconnects!
        	
        	for(var x = 0; x < lhist[asset.index].size(); x++){ 
        		pl.addLocation(lhist[asset.index][x]);
        		
        		var l = lhist[asset.index][x].toDegrees();
        		
        		if(tlat == null || l[0] > tlat) {
        			tlat = l[0];
        		}
        		if(tlon == null || l[1] < tlon) {
        			tlon = l[1];
        		}
        		if(blat == null || l[0] < blat) {
        			blat = l[0];
        		}
        		if(blon == null || l[1] > blon) {
        			blon = l[1];
        		}
        	}
        }
        // add the latest location to make sure the line connects to the marker
        pl.addLocation(new Position.Location({
            :latitude => asset.latitude,
            :longitude =>asset.longitude,
            :format => :degrees
        }));
        
        
        // add markers
        var allMarkers = [];
        for(var i = 0; i < assets.size(); i++){
        	System.println("generating marker (i)");
        	var marker = new WatchUi.MapMarker(
		        new Position.Location({
		            :latitude => assets[i].latitude,
		            :longitude =>assets[i].longitude,
		            :format => :degrees
		        })
		    );
            marker.setIcon(WatchUi.MAP_MARKER_ICON_PIN, 0, 0);
            marker.setLabel(assets[i].name);
			allMarkers.add(marker);
        
        }
        //MapView.clear();
        if(null != blat && null != blon && null != tlat && null != tlon) {
        	System.println("map reposition");
        	var diff = 0.0005;
	        var top_left = new Position.Location({:latitude => tlat+diff, :longitude =>tlon-diff, :format => :degrees});
	        var bottom_right = new Position.Location({:latitude => blat-diff, :longitude =>blon+diff, :format => :degrees});
	        MapView.setMapVisibleArea(top_left, bottom_right);
        }
        MapView.setMapMarker(allMarkers);
        MapView.setPolyline(pl);
       	//WatchUi.requestUpdate();
       	 System.println("updateMapdata");
	    
	}
	
	function onUpdate(dc) {
		
        MapView.onUpdate(dc);
        System.println("Onupdate");
        // (do not need to call this?) 
	}
    // returns own position, or default in case of not available (for some reason?)
    function getOwnPosition() {
    	System.println("getownposition");
    	var positionInfo = Position.getInfo();
    	if (positionInfo has :position && positionInfo.position != null) {
    		return positionInfo.position;
    	}
    	return new Position.Location({:latitude => 38.85695, :longitude =>-94.80051, :format => :degrees});
    }
    
    // copypasta from list view @todo
    hidden function getColor(assetColor) {
    	var blue = (assetColor >> 6)& 0x03;
    	var green = (assetColor >> 3)& 0x07;
    	var red = assetColor & 0x07;
    	
    	red = ((red.toFloat()/0x07)*255).toLong();
    	green = ((green.toFloat()/0x07)*255).toLong();
    	blue = ((blue.toFloat()/0x03)*255).toLong();
    	
    	return (red << 16) | (green << 8) | blue;
    }
}
class DogMapBehaviorDelegate extends WatchUi.BehaviorDelegate 
{
	var view;
	
	function initialize(pView) {
		WatchUi.BehaviorDelegate.initialize();
		view = pView;
	}
 	
    function onPreviousPage() 
    {	
    	if(view.assetIndex > 0) {
    		view.assetIndex--;
    		view.updateMapData();
    		WatchUi.requestUpdate();
    		return true;
    	}
    	WatchUi.popView(WatchUi.SLIDE_UP);
    	return true;
    }
    function onNextPage() {
    	if(view.assetIndex < Application.getApp().getLocationHistory().size()-1) {
    		view.assetIndex++;
    		view.updateMapData();
    		WatchUi.requestUpdate();
    		return true;
    	}
    	return true;
    }
}