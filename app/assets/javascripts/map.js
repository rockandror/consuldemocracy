(function() {
  "use strict";
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
    initializeMap: function(element) {
      var addMarkerInvestments, markerCoordinates, editable,
        map, center,
        marker,
        moveOrPlaceMarker, removeMarker, removeMarkerSelector,
        zoom;
      App.Map.cleanInvestmentCoordinates(element);
      markerCoordinates = App.Map.getMarkerCoordinates(element);
      center = App.Map.getMapCenter(element);
      zoom = App.Map.getMapZoom(element);
      removeMarkerSelector = $(element).data("marker-remove-selector");
      addMarkerInvestments = $(element).data("marker-investments-coordinates");
      editable = App.Map.isEditable(element);
      marker = null;
      removeMarker = function(e) {
        e.preventDefault();
        if (marker) {
          map.removeLayer(marker);
          marker = null;
        }
        App.Map.clearFormfields(map);
      };
      moveOrPlaceMarker = function(e) {
        if (marker) {
          marker.setLatLng(e.latlng);
        } else {
          marker = App.Map.createMarker(map, e.latlng.lat, e.latlng.lng);
        }
        App.Map.updateFormfields(map, marker);
      };
      map = App.Map.buildMap(element, center, zoom);
      if (App.Map.validCoordinates(markerCoordinates) && !addMarkerInvestments) {
        marker = App.Map.createMarker(map, markerCoordinates.lat, markerCoordinates.long);
      }
      if (editable) {
        $(removeMarkerSelector).on("click", removeMarker);
        map.on("zoomend", function() {
          if (marker) {
            App.Map.updateFormfields(map, marker);
          }
        });
        map.on("click", moveOrPlaceMarker);
      }
      if (addMarkerInvestments) {
        addMarkerInvestments.forEach(function(coordinates) {
          if (App.Map.validCoordinates(coordinates)) {
            marker = App.Map.createMarker(map, coordinates.lat, coordinates.long);
            marker.options.id = coordinates.investment_id;
            marker.on("click", App.Map.openMarkerPopup);
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
          App.Map.updateFormfields(map, marker);
        });
      }
      marker.addTo(map);
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
      return "<a href='/budgets/" + data.budget_id + "/investments/" + data.investment_id + "'>" + data.investment_title + "</a>";
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
    cleanInvestmentCoordinates: function(element) {
      var clean_markers, markers;
      markers = $(element).attr("data-marker-investments-coordinates");
      if (markers != null) {
        clean_markers = markers.replace(/-?(\*+)/g, null);
        $(element).attr("data-marker-investments-coordinates", clean_markers);
      }
    },
    updateFormfields: function(map, marker) {
      var inputSelectors = App.Map.getInputSelectors(map.getContainer());
      $(inputSelectors.lat).val(marker.getLatLng().lat);
      $(inputSelectors.long).val(marker.getLatLng().lng);
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
