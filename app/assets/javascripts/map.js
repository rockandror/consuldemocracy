(function() {
  "use strict";

  L.Map.include({ marker: null });

  App.Map = {
    maps: [],
    initialize: function() {
      $("*[data-map]:visible").each(function() {
        App.Map.initializeMap(this);
      });
    },
    destroy: function() {
      App.Map.maps.forEach(function(map) {
        map.off();
        map.remove();
      });
      App.Map.maps = [];
    },
    editableMap: function(map) {
      var removeMarkerSelector = $(map.getContainer()).data("marker-remove-selector");
      $(removeMarkerSelector).on("click", function(e) {
        e.preventDefault();
        App.Map.removeMarker(map);
      });
      map.on("zoomend", function() {
        if (map.marker) {
          App.Map.updateFormfields(map);
        }
      });
      map.on("click", function(e) {
        App.Map.moveOrPlaceMarker(map, e);
      });
    },
    initializeMap: function(element) {
      var addMarkerInvestments, markerCoordinates,
        map, center,
        zoom;
      App.Map.cleanInvestmentCoordinates(element);
      markerCoordinates = App.Map.getMarkerCoordinates(element);
      center = App.Map.getMapCenter(element);
      zoom = App.Map.getMapZoom(element);
      addMarkerInvestments = $(element).data("marker-investments-coordinates");
      map = App.Map.buildMap(element, center, zoom);
      if (App.Map.validCoordinates(markerCoordinates) && !addMarkerInvestments) {
        map.marker = App.Map.createMarker(map, markerCoordinates.lat, markerCoordinates.long);
      }
      if (App.Map.isEditable(element)) {
        App.Map.editableMap(map);
      }
      if (addMarkerInvestments) {
        addMarkerInvestments.forEach(function(coordinates) {
          if (App.Map.validCoordinates(coordinates)) {
            map.marker = App.Map.createMarker(map, coordinates.lat, coordinates.long);
            map.marker.options.id = coordinates.investment_id;
            map.marker.on("click", App.Map.openMarkerPopup);
          }
        });
      }
    },
    isEditable: function(element) {
      return $(element).data("marker-editable");
    },
    buildMap: function(element, center, zoom) {
      var map, mapTilesProvider, mapAttribution;
      map = L.map(element.id).setView(center, zoom);
      mapTilesProvider = $(element).data("map-tiles-provider");
      mapAttribution = $(element).data("map-tiles-provider-attribution");
      L.tileLayer(mapTilesProvider, {
        attribution: mapAttribution
      }).addTo(map);
      App.Map.maps.push(map);
      return map;
    },
    buildMarkerIcon: function() {
      return L.divIcon({
        className: "map-marker",
        iconSize: [30, 30],
        iconAnchor: [15, 40],
        html: '<div class="map-icon"></div>'
      });
    },
    clearFormfields: function(map) {
      var inputSelectors = App.Map.getInputSelectors(map.getContainer());
      $(inputSelectors.lat).val("");
      $(inputSelectors.long).val("");
      $(inputSelectors.zoom).val("");
    },
    createMarker: function(map, latitude, longitude) {
      var element, marker, markerLatLng;
      element = map.getContainer();
      markerLatLng = new L.LatLng(latitude, longitude);
      marker = L.marker(markerLatLng, {
        icon: App.Map.buildMarkerIcon(),
        draggable: App.Map.isEditable(element)
      });
      if (App.Map.isEditable(element)) {
        marker.on("dragend", function() {
          App.Map.updateFormfields(map);
        });
      }
      marker.addTo(map);
      map.marker = marker;
      return marker;
    },
    getInputSelectors: function(element) {
      return {
        lat: $(element).data("latitude-input-selector"),
        long: $(element).data("longitude-input-selector"),
        zoom: $(element).data("zoom-input-selector")
      };
    },
    getCurrentMarkerLocation: function(element) {
      var inputSelectors = App.Map.getInputSelectors(element);
      return {
        lat: $(inputSelectors.lat).val(),
        long: $(inputSelectors.long).val(),
        zoom: $(inputSelectors.zoom).val()
      };
    },
    getDefaultMapSettings: function(element) {
      return {
        lat: $(element).data("map-center-latitude"),
        long: $(element).data("map-center-longitude"),
        zoom: $(element).data("map-zoom")
      };
    },
    getMapCenter: function(element) {
      var defaultMapSettings, markerCoordinates;
      markerCoordinates = App.Map.getMarkerCoordinates(element);
      if (App.Map.validCoordinates(markerCoordinates)) {
        return new L.LatLng(markerCoordinates.lat, markerCoordinates.long);
      } else {
        defaultMapSettings = App.Map.getDefaultMapSettings(element);
        return new L.LatLng(defaultMapSettings.lat, defaultMapSettings.long);
      }
    },
    getMarkerCoordinates: function(element) {
      var formCoordinates = App.Map.getCurrentMarkerLocation(element);
      if (App.Map.validCoordinates(formCoordinates)) {
        return formCoordinates;
      } else {
        return {
          lat: $(element).data("marker-latitude"),
          long: $(element).data("marker-longitude")
        };
      }
    },
    getMapZoom: function(element) {
      var defaultMapSettings, formCoordinates;
      formCoordinates = App.Map.getCurrentMarkerLocation(element);
      if (App.Map.validZoom(formCoordinates.zoom)) {
        return formCoordinates.zoom;
      } else {
        defaultMapSettings = App.Map.getDefaultMapSettings(element);
        return defaultMapSettings.zoom;
      }
    },
    getPopupContent: function(data) {
      var url = "/budgets/" + data.budget_id + "/investments/" + data.investment_id;
      return "<a href='" + url + "'>" + data.investment_title + "</a>";
    },
    moveOrPlaceMarker: function(map, event) {
      if (map.marker) {
        map.marker.setLatLng(event.latlng);
      } else {
        map.marker = App.Map.createMarker(map, event.latlng.lat, event.latlng.lng);
      }
      App.Map.updateFormfields(map);
    },
    openMarkerPopup: function(event) {
      var marker = event.target;
      $.ajax("/investments/" + marker.options.id + "/json_data", {
        type: "GET",
        dataType: "json",
        success: function(data) {
          event.target.bindPopup(App.Map.getPopupContent(data)).openPopup();
        }
      });
    },
    removeMarker: function(map) {
      if (map.marker) {
        map.removeLayer(map.marker);
        map.marker = null;
      }
      App.Map.clearFormfields(map);
    },
    cleanInvestmentCoordinates: function(element) {
      var clean_markers, markers;
      markers = $(element).attr("data-marker-investments-coordinates");
      if (markers != null) {
        clean_markers = markers.replace(/-?(\*+)/g, null);
        $(element).attr("data-marker-investments-coordinates", clean_markers);
      }
    },
    updateFormfields: function(map) {
      var inputSelectors = App.Map.getInputSelectors(map.getContainer());
      $(inputSelectors.lat).val(map.marker.getLatLng().lat);
      $(inputSelectors.long).val(map.marker.getLatLng().lng);
      $(inputSelectors.zoom).val(map.getZoom());
    },
    validZoom: function(zoom) {
      return App.Map.isNumeric(zoom);
    },
    validCoordinates: function(coordinates) {
      return App.Map.isNumeric(coordinates.lat) && App.Map.isNumeric(coordinates.long);
    },
    isNumeric: function(n) {
      return !isNaN(parseFloat(n)) && isFinite(n);
    }
  };
}).call(this);
