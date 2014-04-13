// Load data tiles from an AJAX data source
L.TileLayer.Ajax = L.TileLayer.extend({
    _requests: [],
    _addTile: function (tilePoint) {
        var tile = { datum: null, processed: false };
        console.log("original " + this.getTileUrl(tilePoint));
        zoom = this._map._zoom;
        this._tiles[tilePoint.x + ':' + tilePoint.y] = tile;
        this._loadTile(zoom, tile, tilePoint);
    },
    // XMLHttpRequest handler; closure over the XHR object, the layer, and the tile
    _xhrHandler: function (req, layer, tile, tilePoint) {
        return function () {
            if (req.readyState !== 4) {
                return;
            }
            var s = req.status;
            if ((s >= 200 && s < 300) || s === 304) {
                tile.datum = JSON.parse(req.responseText);
                layer._tileLoaded(tile, tilePoint);
            } else {
                layer._tileLoaded(tile, tilePoint);
            }
        };
    },
    // Load the requested tile via AJAX
    _loadTile: function (zoom, tile, tilePoint) {
//        this._adjustTilePoint(tilePoint);

        console.log("_loadTile("+zoom+", "+tile+", "+tilePoint+")");

        if (zoom < 14) { // maximum zoom level
            console.log(zoom + " " + tilePoint.x + " " + tilePoint.y);
            tempX = tilePoint.x * 2;
            tempY = tilePoint.y * 2;
            newZoom = zoom + 1;
            console.log(newZoom + " " + tempX + " " + tempY);

            tilePoint1 = tilePoint.clone();
            tilePoint1.x = tempX;
            tilePoint1.y = tempY;
            console.log(newZoom + " " + tilePoint1.x + " " + tilePoint1.y);

            this._tiles[tilePoint1.x + ':' + tilePoint1.y] = tile;
            this._loadTile(zoom + 1, tile, tilePoint1);

            tilePoint2 = tilePoint.clone();
            tilePoint2.x = tempX + 1;
            tilePoint2.y = tempY;
            this._tiles[tilePoint2.x + ':' + tilePoint2.y] = tile;
            this._loadTile(zoom + 1, tile, tilePoint2);

            tilePoint3 = tilePoint.clone();
            tilePoint3.x = tempX;
            tilePoint3.y = tempY + 1;
            this._tiles[tilePoint3.x + ':' + tilePoint3.y] = tile;
            this._loadTile(zoom + 1, tile, tilePoint3);

            tilePoint4 = tilePoint.clone();
            tilePoint4.x = tempX + 1;
            tilePoint4.y = tempY + 1;
            this._tiles[tilePoint4.x + ':' + tilePoint4.y] = tile;
            this._loadTile(zoom + 1, tile, tilePoint4);
        } else {
            originalZoom = this._map._zoom;
//            json_url = this.getTileUrl(tilePoint).replace("plaques/"+originalZoom+"/","plaques/"+zoom+"/");
            json_url = "/plaques/"+zoom+"/"+tilePoint.x+"/"+tilePoint.y+".json";
            console.log("b " + json_url);
            var layer = this;
            var req = new XMLHttpRequest();
            this._requests.push(req);
            req.onreadystatechange = this._xhrHandler(req, layer, tile, tilePoint);
            req.open('GET', json_url, true);
            req.send();
        }
    },
    _reset: function () {
        L.TileLayer.prototype._reset.apply(this, arguments);
        for (var i in this._requests) {
            this._requests[i].abort();
        }
        this._requests = [];
    },
    _update: function () {
        if (this._map._panTransition && this._map._panTransition._inProgress) { return; }
        if (this._tilesToLoad < 0) { this._tilesToLoad = 0; }
        L.TileLayer.prototype._update.apply(this, arguments);
    }
});


L.TileLayer.GeoJSON = L.TileLayer.Ajax.extend({
    // Store each GeometryCollection's layer by key, if options.unique function is present
//    _keyLayers: {},

    initialize: function (url, options, geojsonOptions) {
        L.TileLayer.Ajax.prototype.initialize.call(this, url, options);
        this.geojsonLayer = new L.GeoJSON(null, geojsonOptions);
    },

    onAdd: function (map) {
        this._map = map;
        L.TileLayer.Ajax.prototype.onAdd.call(this, map);
        map.addLayer(this.geojsonLayer);
    },

    onRemove: function (map) {
        map.removeLayer(this.geojsonLayer);
        L.TileLayer.Ajax.prototype.onRemove.call(this, map);
    },

    _reset: function () {
        this.geojsonLayer.clearLayers();
        L.TileLayer.Ajax.prototype._reset.apply(this, arguments);
    },

    _recurseLayerUntilPath: function (func, layer) {
        if (layer instanceof L.Path) {
            func(layer);
        }
        else if (layer instanceof L.LayerGroup) {
            layer.getLayers().forEach(this._recurseLayerUntilPath.bind(this, func), this);
        }
    },

    // Add a geojson object from a tile to the GeoJSON layer
    addTileData: function (geojson, tilePoint) {
        var features = L.Util.isArray(geojson) ? geojson : geojson.features, i, len, feature;
        if (features) {
            for (i = 0, len = features.length; i < len; i++) {
                feature = features[i];
                if (feature.geometries || feature.geometry || feature.features || feature.coordinates) {
                    this.addTileData(features[i], tilePoint);
                }
            }
            return this;
        }
        var options = this.geojsonLayer.options;
        var parentLayer = this.geojsonLayer;
        var incomingLayer = null;
        try {
            incomingLayer = L.GeoJSON.geometryToLayer(geojson, options.pointToLayer, options.coordsToLatLng);
        }
        catch (e) {
            return this;
        }
        incomingLayer.feature = L.marker(geojson.geometry.coordinates);
        incomingLayer.defaultOptions = incomingLayer.options;
        this.geojsonLayer.resetStyle(incomingLayer);
        if (options.onEachFeature) {
            options.onEachFeature(geojson, incomingLayer);
        }
        parentLayer.addLayer(incomingLayer);
        return this;
    },

    _tileLoaded: function (tile, tilePoint) {
        L.TileLayer.Ajax.prototype._tileLoaded.apply(this, arguments);
        if (tile.datum === null) { return null; }
        this.addTileData(tile.datum, tilePoint);
    }
});
