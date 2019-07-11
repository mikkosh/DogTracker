<?php
/**
 * This is a sample Beacon file for Dog Tracker App
 * 
 * The script receives the data send from a Garmin device (in a POST message), parses it
 * and saves it locally in a JSON format. When the script receives a GET request
 * it displays a map with the collected location data.
 *
 * Note! This should not be used in production (which is obvious when you read the code).
 * This was copy pasted together in 15 minutes and has absolutely no security checks.
 */
 
if(isset($_POST) && count($_POST) > 0) {
        $arrJson = [];
        foreach($_POST as $key => $val) {
                if(0 === strpos($key, 'dog-')) {
                        $dogIdAndField = substr($key, 4);
                        print_r($dogIdAndField);
                        $dogId = substr($dogIdAndField,0,strpos($dogIdAndField,'-'));
                        $field = substr($dogIdAndField,strpos($dogIdAndField,'-')+1);
                        if(!isset($arrJson[$dogId])) {
                                $arrJson[$dogId] = [];
                        }
                        $arrJson[$dogId][$field] = $val;
                }
        }
        file_put_contents("garmin.json",json_encode($arrJson));
}else {
?>
<html>
<head>
<script type='text/javascript' src='//wp-includes/js/jquery/jquery.js?ver=1.12.4'></script>
<script type='text/javascript'>
var DogMap = {
        map: null,
        positions: {},
        polylines: [],
        dogInfo: {},
        initMap: function() {
                var that = this;
                this.map = new google.maps.Map(document.getElementById('map'), {
                        center : {
                                lat : 63.648432,
                                lng : 29.118716
                        },
                        zoom : 15,
                        scaleControl : true,
                        streetViewControl : false,
                        gestureHandling: 'greedy'
                });
        },
        updateMarkers: function() {
                jQuery.getJSON( "garmin.json", function( data ) {
                        console.log(data);
                        jQuery.each(data, function(i, rowData) {
                                if(typeof DogMap.positions[i] === 'undefined'){
                                        DogMap.positions[i] = [];
                                        DogMap.dogInfo[i] = {color:DogMap.getColor(rowData.color)};
                                }
                                DogMap.positions[i].push({lat:parseFloat(rowData.latitude), lng:parseFloat(rowData.longitude)});
                        });
                        jQuery.each(DogMap.polylines, function(i, line) {
                                line.setMap(null);
                        });
                        DogMap.polylines = [];

                        jQuery.each(DogMap.positions, function(i, line){
                                var pl = new google.maps.Polyline(
                                        {
                                                path : line,
                                                strokeColor : DogMap.dogInfo[i].color,//'#f00', // todo: whatif not enuf colors
                                                strokeOpacity : 1.0,
                                                strokeWeight : 3,
                                                icons : [ {
                                                        icon : {
                                                                path : google.maps.SymbolPath.FORWARD_CLOSED_ARROW
                                                        },
                                                        offset : '100%'
                                                } ]
                                        });
                                        pl.setMap(DogMap.map);
                                DogMap.polylines.push(pl);
                        });
                        console.log(DogMap.positions);
                    });
        },
        getColor:function (assetColor) {
                assetColor = parseInt(assetColor);
                var blue = (assetColor >> 6)& 0x03;
                var green = (assetColor >> 3)& 0x07;
                var red = assetColor & 0x07;

                red = parseInt(((red/0x07)*255));
                green = parseInt(((green/0x07)*255));
                blue = parseInt(((blue/0x03)*255));

                var rgbToHex = function (rgb) {
                        var hex = Number(rgb).toString(16);
                        if (hex.length < 2) {
                                hex = "0" + hex;
                        }
                        return hex;
                };

                return "#" + rgbToHex(red) + rgbToHex(green) + rgbToHex(blue);
    }
}
</script>
</head>
<body>
<h1>Dog tracker map</h1>
<div id="map" style="width:100%;height:80%;"></div>
<script type='text/javascript'>
jQuery(function() {
var mapScript = 'https://maps.googleapis.com/maps/api/js?key=AIzaSyCCmr7cczc2nXZEJop8d4XNEnzyGwnEz6I&callback=DogMap.initMap';
jQuery('body').append('\x3Cscript type="text/javascript" src="'+mapScript+'">\x3C/script>');
window.setInterval(DogMap.updateMarkers, 10000);
if (navigator.geolocation) {
     navigator.geolocation.getCurrentPosition(function (position) {
         initialLocation = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
         DogMap.map.setCenter(initialLocation);
     });
 }
});
</script>
</body>
</html>



<?php
}
