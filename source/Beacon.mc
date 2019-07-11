using Toybox.Communications;

class Beacon {
	
	var serverUrl;
	
	function initialize(url) {
		serverUrl = url;
	}
	
	function onReceive(responseCode, data){
		if (responseCode == 200) {
           System.println("Request Successful");                   
       }
       else {
           System.println("Response: " + responseCode);            
       }
	}
	
	function sendAssetData(assets) {
		var params = {};
		for(var i = 0; i < assets.size(); i++){
            var ass = assets[i];
            params["dog-"+i+"-index"] = ass.index;
            params["dog-"+i+"-name"] = ass.name;
            params["dog-"+i+"-distance"] = ass.distance;
            params["dog-"+i+"-bearingDeg"] = ass.bearingDeg;
            params["dog-"+i+"-latitude"] = ass.latitude;
            params["dog-"+i+"-longitude"] = ass.longitude;
            
            params["dog-"+i+"-color"] = ass.color;
            params["dog-"+i+"-type"] = ass.type;
            params["dog-"+i+"-dstat"] = "S" + ass.situation + "/B"+ass.isLowBattery+"/G"+ass.isGPSLost+"/C"+ass.isCommLost+"/!"+ass.shouldRemove;
         }
	
       var options = {                                             // set the options
           :method => Communications.HTTP_REQUEST_METHOD_POST,      // set HTTP method
           :headers => {                                           // set headers
                   "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED},
                                                                   // set response type
           :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_URL_ENCODED
       };

       var responseCallback = method(:onReceive);                  // set responseCallback to
                                                                   // onReceive() method
       // Make the Communications.makeWebRequest() call
       Communications.makeWebRequest(serverUrl, params, options, method(:onReceive));
	}
}