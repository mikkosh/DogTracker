using Toybox.WatchUi;
using Toybox.Timer;
using Toybox.Attention;
using Toybox.System;
using AntAssetTracker;
using Toybox.Application;
using Toybox.Graphics as Gfx;

class ConnectingView extends WatchUi.View {

	hidden var timer = null;

	function initialize() {
		WatchUi.View.initialize();
	}
	
	function onShow() {
		timer = new Timer.Timer();
    	timer.start(method(:timerCallback), 2000, true);
	}
	
	function onHide() {
		timer.stop();
	}
	
	function onUpdate(dc) {
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
	    dc.clear();
		dc.drawText(dc.getHeight()/2, dc.getWidth()/2, Gfx.FONT_MEDIUM, "Connecting", Gfx.TEXT_JUSTIFY_CENTER|Gfx.TEXT_JUSTIFY_VCENTER);
	}
	
	function timerCallback() {
		
		if(Application.getApp().sensor == null) {
			// total fail, could not get a channel
			System.println("NO CHANNEL!!");
			//System.exit();
		}
	    if(Application.getApp().sensor.searching == false) {
	    	
	    	notifyConnect();
	    	// push view
	    	WatchUi.pushView(new ListView(), new ListBehaviorDelegate(), WatchUi.SLIDE_UP);
	    }
	}
	
	hidden function notifyConnect() {
		if (Attention has :vibrate) {
		    var vibeData =
		    [
		        new Attention.VibeProfile(100, 2000)
		    ];
		    Attention.vibrate(vibeData);
		}
	}

}