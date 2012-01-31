var map;
var ajaxRequest;
var plotlist;
var plotlayers=[];

var PlaqueIcon = L.Icon.extend({
    iconUrl: '/assets/images/marker.png',
    shadowUrl: '/assets/images/marker-shadow.png',
});

function getXmlHttpObject() {
  if (window.XMLHttpRequest) { return new XMLHttpRequest(); }
  if (window.ActiveXObject)  { return new ActiveXObject("Microsoft.XMLHTTP"); }
  return null;
}

function stateChanged() {
  // if AJAX returned a list of markers, add them to the map
  if (ajaxRequest.readyState==4) {
    //use the info here that was returned
    if (ajaxRequest.status==200) {

      plotlist=eval("(" + ajaxRequest.responseText + ")");
      removeMarkers();
      for (i=0;i<plotlist.length;i++) {

        var plaque = plotlist[i].plaque;
        var plotll = new L.LatLng(plotlist[i].plaque.latitude,plotlist[i].plaque.longitude, true);
        var plaque_icon = new PlaqueIcon();
        var plotmark = new L.Marker(plotll, {icon: plaque_icon});
        plotmark.data=plotlist[i];
        map.addLayer(plotmark);

        if (plaque.inscription.length > 200) {
          var text = plaque.inscription.substring(0,200) + "...";
        } else {
          var text = plaque.inscription;
        }
        plotmark.bindPopup('<h3>'+plaque.title+'</h3><p>'+text+'</p><p><a href="http://openplaques.org/plaques/'+plaque.id+'">View on Open Plaques</a></p>');
        plotlayers.push(plotmark);
      }

    }
  }
}

function removeMarkers() {
  for (i=0;i<plotlayers.length;i++) {
    map.removeLayer(plotlayers[i]);
  }
  plotlayers=[];
}


function askForPlots() {
  // request the marker info with AJAX for the current bounds
  var bounds=map.getBounds();
  var minll=bounds.getSouthWest();
  var maxll=bounds.getNorthEast();
  var msg='/plaques.json?box=['+maxll.lat+','+minll.lng+'],['+minll.lat+','+maxll.lng+']&limit=2000&data=simple';


//   var msg = 'http://openplaques.org/plaques.json?box=[51.5482,-0.1617],[51.5282,-0.1217]'
  ajaxRequest.onreadystatechange = stateChanged;
  ajaxRequest.open('GET', msg, true);
  ajaxRequest.send(null);
}

function initmap() {

  var plaque_map = $("#plaque-map");

  if (plaque_map) {

      // set up AJAX request
      ajaxRequest=getXmlHttpObject();
      if (ajaxRequest==null) {
        // alert ("This browser does not support HTTP Request");
        return;
      }

      // set up the map
      map = new L.Map('plaque-map');

      // create the tile layer with correct attribution
    //  var osmUrl='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png';
    //   var osmAttrib='Map data © OpenStreetMap contributors';
    //   var osm = new L.TileLayer(osmUrl, {minZoom: 8, maxZoom: 15, attribution: osmAttrib});

      var mapquestUrl = 'http://{s}.mqcdn.com/tiles/1.0.0/osm/{z}/{x}/{y}.png',
      subDomains = ['otile1','otile2','otile3','otile4'],
      mapquestAttrib = 'Data, imagery and map information provided by <a href="http://open.mapquest.co.uk" target="_blank">MapQuest</a>, <a href="http://www.openstreetmap.org/" target="_blank">OpenStreetMap</a> and contributors.';
      var mapquest = new L.TileLayer(mapquestUrl, {maxZoom: 18, attribution: mapquestAttrib, subdomains: subDomains});


      var latitude = plaque_map.attr("data-latitude");
      var longitude = plaque_map.attr("data-longitude");
      var zoom = plaque_map.attr("data-zoom");

      if (zoom) {
        var zoom_level = parseInt(zoom);
      } else {
        var zoom_level = 14
      }

      if (latitude && longitude) {
        map.setView(new L.LatLng(parseFloat(latitude),parseFloat(longitude)),zoom_level);
      } else {
        // start the map in London
        map.setView(new L.LatLng(51.54281206119232,-0.16788482666015625),zoom_level);
      }

      map.addLayer(mapquest);
      askForPlots();
      map.on('moveend', onMapMove);

  }

}

  // then add this as a new function...
function onMapMove(e) { askForPlots(); }

$(document).ready(function() {
  if ($("#plaque-map")) {
    initmap();
  }
})