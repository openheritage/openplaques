// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

function addLoadEvent(func) {
  var oldonload = window.onload;
  if (typeof window.onload != 'function') {
    window.onload = func;
  } else {
    window.onload = function() {
      if (oldonload) {
        oldonload();
      }
      func();
    }
  }
}

 function addMap(lat,lon,featurecollection) {

﻿   var zoom = 9;﻿  
﻿   OpenLayers.IMAGE_RELOAD_ATTEMPTS = 3;
﻿   OpenLayers.Util.onImageLoadErrorColor = "transparent";﻿  
     var options = {
         projection: new OpenLayers.Projection("EPSG:900913"),
         displayProjection: new OpenLayers.Projection("EPSG:4326"),
         units: "m",
         numZoomLevels: 18,
         maxResolution: 156543.0339,
         maxExtent: new OpenLayers.Bounds(-20037508, -20037508,
                                          20037508, 20037508.34)
     };
     var map = new OpenLayers.Map('map', options);

     var mapnik = new OpenLayers.Layer.OSM();
     var vector = new OpenLayers.Layer.Vector("OpenPlaques");
     var markers = new OpenLayers.Layer.Markers("Markers");

     map.addLayers([mapnik, markers]);
     map.addControl(new OpenLayers.Control.Permalink());
     map.addControl(new OpenLayers.Control.MousePosition());
     
     var proj = new OpenLayers.Projection("EPSG:4326");
﻿  ﻿  var point = new OpenLayers.LonLat(lon, lat);
﻿  ﻿  point.transform(proj, map.getProjectionObject());

     map.setCenter(point, zoom);
     
     if (!map.getCenter()) {map.zoomToMaxExtent()}
     
    var geojson_format = new OpenLayers.Format.GeoJSON(
      {
        'internalProjection': new OpenLayers.Projection("EPSG:900913"),
        'externalProjection': new OpenLayers.Projection("EPSG:4326")
      }
    );
    vector.addFeatures(geojson_format.read(featurecollection));

    // try using Markers instead
    var size = new OpenLayers.Size(10,17);
    var offset = new OpenLayers.Pixel(-(size.w/2), -size.h);
    var icon = new OpenLayers.Icon('http://boston.openguides.org/markers/AQUA.png',size,offset);
  
        point = new OpenLayers.LonLat(-0.07699, 51.521214);
﻿  ﻿  point.transform(proj, map.getProjectionObject());
        marker = new OpenLayers.Marker(point,icon.clone());
﻿      markers.addMarker(marker);
      
    
 }
 


