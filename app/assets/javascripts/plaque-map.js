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
      
      if (plaque.latitude && plaque.longitude) {

				var plaque_icon = new L.DivIcon({
					className: 'plaque-marker',
					html: '',
					iconSize : 16
				});
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
      }
    }
  }
}

// request the marker info with AJAX for the current bounds
function getPlaques(url) {
  ajaxRequest=getXmlHttpObject();
  ajaxRequest.onreadystatechange = stateChanged;
  ajaxRequest.open('GET', url, true);
  ajaxRequest.send(null);
}

function initmap() {
  var plaque_map = $("#plaque-map");
  if (plaque_map) {
    ajaxRequest=getXmlHttpObject();
    if (ajaxRequest==null) {
      // alert ("This browser does not support HTTP Request");
      return;
    }
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
      var zoom_level = 14
    }

    if (latitude && longitude) {
      map.setView(L.latLng(parseFloat(latitude),parseFloat(longitude)),zoom_level);
    } else {
      // start the map in London
      map.setView(L.latLng(51.54281206119232,-0.16788482666015625),zoom_level);
    }

    var data_view = plaque_map.attr("data-view");
    var data_path = plaque_map.attr("data-path");
    if (data_view && data_view == "all") {
      var url = '/plaques.json';
    } else if (data_path) {
      var url = data_path;
    } else {
	  var url = document.location.href.replace(/\?.*/,'') + '.json';
    }
    if (data_view && data_view == "one") {
      allow_popups=false;
    }
    
    if (data_view == 'one') {
    
			var plaque_icon = new L.DivIcon({
				className: 'plaque-marker',
				html: '',
				iconSize : 16
			});

    	L.marker([parseFloat(latitude),parseFloat(longitude)], {
    		icon: plaque_icon
    	}).addTo(map);
    } else {
	    getPlaques(url);  
    }

  }
}

$(document).ready(function() {
  if ($("#plaque-map").length) {
    initmap();
  }
})