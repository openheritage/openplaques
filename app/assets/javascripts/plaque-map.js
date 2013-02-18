var map;
var ajaxRequest;
var plaques=[];
var allow_popups=true;

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
      if (plaque.latitude && plaque.longitude && plaques["'#"+plaque.id+"'"]==null) { // ensure that we never display a plaque more than once
		var plaque_icon = new L.DivIcon({ className: 'plaque-marker', html: '', iconSize : 16 });
        var plaque_marker = L.marker([plaque.latitude, plaque.longitude], {icon: plaque_icon});
        if (plaque.inscription.length > 200) {
          var text = plaque.inscription.substring(0,200) + "...";
        } else {
          var text = plaque.inscription;
        }
        if (allow_popups==true) {
          plaque_marker.bindPopup('<h3><a href="http://openplaques.org/plaques/'+plaque.id+'">'+plaque.title+'</a></h3><p>'+text+'</p>');
        }
		plaque_marker.addTo(map);
		plaques["'#"+plaque.id+"'"]=plaque;
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
		   var url = '/plaques.json?data=simple&limit=1000';
		} else if (data_path) {
		   var url = data_path;
		} else {
		   var url = document.location.href.replace(/\?.*/,'') + '.json?data=simple&limit=1000';
		}
	    getPlaques(url);  
		map.on('moveend', function() { getPlaques(url) });
	}

  }
}

$(document).ready(function() {
  if ($("#plaque-map").length) {
    initmap();
  }
})