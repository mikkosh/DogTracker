//
// Dog tracker app
// Uses AntAssetTracker barrel
//

using Toybox.Application;
using Toybox.WatchUi;
using Toybox.System;
using Toybox.Time;
using Toybox.Activity;
using Toybox.Graphics as Gfx;
using AppGfx;
using Toybox.Timer;
using Toybox.Position;
using Toybox.Math;
using AntAssetTracker;

using AntAssetTracker;

class ListView extends WatchUi.View {

	hidden var sensor;
    
    var timer;
    
    // Constructor
    function initialize() {
        View.initialize();
        System.println("listview");
        sensor = Application.getApp().sensor;
        
        
    }

	function timerCallback() {
	    
	    WatchUi.requestUpdate();
	}

    function onLayout(dc) {
       //setLayout(Rez.Layouts.MainLayout(dc));
       
      // timer = new Timer.Timer();
    	//timer.start(method(:timerCallback), 500, true);
    }
    
	function onShow() {
       timer = new Timer.Timer();
    	timer.start(method(:timerCallback), 500, true);
    }
	function onHide() {
       timer.stop();
    }

    // Update the view
    function onUpdate(dc) {
    	if(sensor.searching) {
    		WatchUi.popView(WatchUi.SLIDE_RIGHT);
    		return;
    	}
    	var assets = sensor.assets.getAssets();
    	if(assets.size() > 0) {
	    	var assetHeight = dc.getHeight() / assets.size();
	    	System.println(assets.size());
	    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
	        dc.clear();
	        for(var i = 0; i < assets.size(); i++){
            	drawAsset(dc, i*assetHeight, assetHeight, assets[i]);
	        }
		} else {
			System.println("NO assets Found");
			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
	        dc.clear();
	        dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Gfx.FONT_LARGE, "No assets found", Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);
		}
        /*
    	if (sensor == null) {
            findDrawableById("status").setText("No channel!");
        } else if (true == sensor.searching) {
            findDrawableById("status").setText("Searching..."+ myCount);
        } else {
            findDrawableById("status").setText("Connected!"+ myCount);
            
            var assets = sensor.assets.getAssets();
            
            for(var i = 0; i < assets.size(); i++){
            	var ass = assets[i]; 
            	findDrawableById("index").setText("Idx("+i+"):" + ass.index);
	            findDrawableById("distance").setText("Dist:" + ass.distance);
	            findDrawableById("bearing").setText("Dir:" + ass.bearingDeg);
	            findDrawableById("latitude").setText("lat:" + ass.latitude);
	            findDrawableById("longitude").setText("lon:" + ass.longitude);
	            findDrawableById("color").setText("Color:" + ass.color);
	            findDrawableById("type").setText("Type:" + ass.type);
	            findDrawableById("name").setText("Name:" + ass.name);
	            findDrawableById("dstat").setText("S" + ass.situation + "/B"+ass.isLowBattery+"/G"+ass.isGPSLost+"/C"+ass.isCommLost+"/!"+ass.shouldRemove);
	            findDrawableById("dbg").setText("Sz:"+assets.size());
	            
            }
         
        }
       View.onUpdate(dc);
       */
    }
    hidden function drawAsset(dc, topPos, height, data) {
    	var centerY = height/2 + topPos;
    	var centerX = dc.getWidth() / 2;
    	var positionInfo = Position.getInfo();
    	var dogDirection = data.bearingDeg;
    	var headingDeg = 0;
    	
    	if (positionInfo has :heading && positionInfo.heading != null) {
    		// position info gives strange results (like, huge numbers) on simulator unless simulate is on
    		headingDeg = positionInfo.heading * (180 / Math.PI);
    		dogDirection = data.bearingDeg + headingDeg;
    		if(dogDirection>360) {
    			dogDirection -= 360;
    		}
    		
    	}
    	// northarrow is for debug only
    	//var Northarrow = new AppGfx.DirectionArrow({:angle=>headingDeg, :height=>height/5, :width=>height/5,:locX=>centerX+height/2,:locY=>centerY});
    	//Northarrow.draw(dc);
    	
    	var arrow = new AppGfx.DirectionArrow({:angle=>dogDirection, :color=>getColor(data.color),:height=>height/4, :width=>height/4,:locX=>centerX+height/4,:locY=>centerY});
    	arrow.draw(dc);
    	
    	dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
    	dc.drawText(centerX, centerY, Gfx.FONT_LARGE, data.name, Gfx.TEXT_JUSTIFY_RIGHT|Gfx.TEXT_JUSTIFY_VCENTER);
    	
    	
    	dc.drawBitmap(centerX+height/4-16,centerY-16,getDogSituationIcon(data.situation));
    }
    
    // converts colors from 3-3-2 RGB to 24bit
    hidden function getColor(assetColor) {
    	var blue = (assetColor >> 6)& 0x03;
    	var green = (assetColor >> 3)& 0x07;
    	var red = assetColor & 0x07;
    	
    	red = ((red.toFloat()/0x07)*255).toLong();
    	green = ((green.toFloat()/0x07)*255).toLong();
    	blue = ((blue.toFloat()/0x03)*255).toLong();
    	
    	return (red << 16) | (green << 8) | blue;
    }
    
    // returns the resource for dog situation
	hidden function getDogSituationIcon(situation) {
		
		var resource = Rez.Drawables.DogUnknown;
		
		if(situation ==AntAssetTracker.STATUS_SITTING){
			resource = Rez.Drawables.DogSitting;
		} else if(situation ==AntAssetTracker.STATUS_MOVING){
			resource = Rez.Drawables.DogMoving;
		} else if(situation ==AntAssetTracker.STATUS_TREED){
			resource = Rez.Drawables.DogTreed;
		} else if(situation ==AntAssetTracker.STATUS_POINTED){ // @todo
			resource = Rez.Drawables.DogPointed;
		}
		return WatchUi.loadResource( resource );
	}
}
class ListBehaviorDelegate extends WatchUi.BehaviorDelegate 
{

	function initialize() {
		WatchUi.BehaviorDelegate.initialize();
	}
 	
    function onNextPage() 
    {	
    	var assets = Application.getApp().sensor.assets.getAssets();
    	if(assets.size() > 0) {
    		var v = new DogMapView(0);
    		WatchUi.pushView(v, new DogMapBehaviorDelegate(v), WatchUi.SLIDE_UP);
    	}
    	
    	
    	return true;
    }
}

