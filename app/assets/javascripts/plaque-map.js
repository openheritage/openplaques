var map;
var ajaxRequest;
var plaques=[];
var allow_popups=true;
var plaque_markers = {};


function getXmlHttpObject() {
  if (window.XMLHttpRequest) { return new XMLHttpRequest(); }
  if (window.ActiveXObject)  { return new ActiveXObject("Microsoft.XMLHTTP"); }
  return null;
}

function stateChanged() {
  // if AJAX returned a list of markers, add them to the map
  if (ajaxRequest.readyState==4 && ajaxRequest.status==200) {
    var answer = ajaxRequest.responseText;
	if (answer.substring(0, 1)=="{") { answer = "["+answer+"]"; } // it is a plaque itself, not an array of plaques
    var json=JSON.parse(answer);
    for (i=0;i<json.length;i++) {
      var plaque = json[i].plaque;
      if (plaque.latitude && plaque.longitude && plaques["'#"+plaque.uri+"'"]==null) { // ensure that we never display a plaque more than once
	
		var plaque_icon = new L.DivIcon({ className: 'plaque-marker', html: '', iconSize : 16 });
        var plaque_marker = L.marker([plaque.latitude, plaque.longitude], {icon: plaque_icon});
        
        if (allow_popups==true) {
					var plaque_description = '<div class="inscription">' + truncate(plaque.inscription, 255) + '</div><div class="info">' +
						'<a class="link" href="http://openplaques.org/plaques/' + plaque.id + '">Plaque ' + plaque.id + '</a>';

          plaque_marker.bindPopup(plaque_description);
        }
		plaque_markers.addLayer(plaque_marker)
		plaques["'#"+plaque.uri+"'"]=plaque;
      }
    }
  }
}

var msg;
// request the marker info with AJAX for the current bounds
function getPlaques(url) {
  var bounds=map.getBounds();
  var minll=bounds.getSouthWest(), maxll=bounds.getNorthEast();
  //  bounding box call, e.g. http://openplaques.org/plaques.json?box=[51.5482,-0.1617],[51.5282,-0.1217]
  msg = url + '&box=['+maxll.lat+','+minll.lng+'],['+minll.lat+','+maxll.lng+']';
  ajaxRequest=getXmlHttpObject();
  ajaxRequest.onreadystatechange = stateChanged;
  ajaxRequest.open('GET', msg, true);
  ajaxRequest.send(null);
}

function initmap() {
  var plaque_map = $("#plaque-map");
  if (plaque_map) {
    map = L.map('plaque-map');
    var mapquestUrl = 'http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png',
    subDomains = ['otile1','otile2','otile3','otile4'],
    mapquestAttrib = 'Map from <a href="http://open.mapquest.co.uk" target="_blank">MapQuest</a> &amp; <a href="http://www.openstreetmap.org/" target="_blank">OSM</a>.';
    var mapquest = new L.TileLayer(mapquestUrl, {maxZoom: 18, attribution: mapquestAttrib, subdomains: subDomains});
    map.addLayer(mapquest);

    var latitude = plaque_map.attr("data-latitude"), longitude = plaque_map.attr("data-longitude"), zoom = plaque_map.attr("data-zoom");
    if (zoom) {
      var zoom_level = parseInt(zoom);
    } else {
      var zoom_level = 14;
    }

    if (latitude && longitude) {
      map.setView(L.latLng(parseFloat(latitude),parseFloat(longitude)),zoom_level);
    } else {
      // start the map in London
      map.setView(L.latLng(51.54281206119232,-0.16788482666015625),zoom_level);
    }

    var data_view = plaque_map.attr("data-view");
    if (data_view == "one") {
		var plaque_icon = new L.DivIcon({ className: 'plaque-marker', html: '', iconSize : 16 });
    	L.marker([parseFloat(latitude),parseFloat(longitude)], { icon: plaque_icon }).addTo(map);
    } else {
		var data_path = plaque_map.attr("data-path");
		if (data_view == "all") {
		   var url = '/plaques.json?data=basic';
		} else if (data_path) {
		   var url = data_path;
		} else {
		   var url = document.location.href.replace(/\?.*/,'') + '.json?data=simple&limit=1000';
		}
		
		plaque_markers = new L.MarkerClusterGroup({
			maxClusterRadius : 25,
			showCoverageOnHover : false,
			iconCreateFunction: function(cluster) {
        return new L.DivIcon({ 
        	html: cluster.getChildCount(), 
        	className : 'plaque-cluster-marker ' + clusterSize(cluster.getChildCount()), 
        	iconSize: clusterWidth(cluster.getChildCount())
        });
    	}				
		});
		
		map.addLayer(plaque_markers);

		
	    getPlaques(url);  

		if (url === '/plaques.json?data=basic') {
		} else {		
			map.on('moveend', function() { getPlaques(url) });
		}


	}

  }
}


function clusterSize(number) {
	
	if (number < 10) {
		return 'small';
	} else if (number < 100) {
		return 'medium';
	} else  {
		return 'large';
	}

}

function clusterWidth(number) {
	
	if (number < 10) {
		return 20;
	} else if (number < 100) {
		return 30;
	} else  {
		return 40;
	}

}

function truncate(string, max_length) {

	if (string.length > max_length) {
		return string.substring(0, max_length) + '...';
	} else {
		return string;
	}

}

$(document).ready(function() {
  if ($("#plaque-map").length) {
    initmap();
  }
})