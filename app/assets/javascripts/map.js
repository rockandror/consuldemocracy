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
      var addMarkerInvestments, clearFormfields, createMarker, markerCoordinates, editable, formCoordinates,
        getPopupContent, inputSelectors, map, center, defaultMapSettings,
        marker, markerIcon,
        moveOrPlaceMarker, openMarkerPopup, removeMarker, removeMarkerSelector,
        updateFormfields, zoom;
      App.Map.cleanInvestmentCoordinates(element);
      inputSelectors = App.Map.getInputSelectors(element);
      defaultMapSettings = App.Map.getDefaultMapSettings(element);
      formCoordinates = App.Map.getCurrentMarkerLocation(element);
      markerCoordinates = App.Map.getMarkerCoordinates(element);
      center = App.Map.getMapCenter(element);
      if (App.Map.validZoom(formCoordinates.zoom)) {
        zoom = formCoordinates.zoom;
      } else {
        zoom = defaultMapSettings.zoom;
      }
      removeMarkerSelector = $(element).data("marker-remove-selector");
      addMarkerInvestments = $(element).data("marker-investments-coordinates");
      editable = App.Map.isEditable(element);
      marker = null;
      markerIcon = L.divIcon({
        className: "map-marker",
        iconSize: [30, 30],
        iconAnchor: [15, 40],
        html: '<div class="map-icon"></div>'
      });
      createMarker = function(latitude, longitude) {
        var markerLatLng;
        markerLatLng = new L.LatLng(latitude, longitude);
        marker = L.marker(markerLatLng, {
          icon: markerIcon,
          draggable: editable
        });
        if (editable) {
          marker.on("dragend", updateFormfields);
        }
        marker.addTo(map);
        return marker;
      };
      removeMarker = function(e) {
        e.preventDefault();
        if (marker) {
          map.removeLayer(marker);
          marker = null;
        }
        clearFormfields();
      };
      moveOrPlaceMarker = function(e) {
        if (marker) {
          marker.setLatLng(e.latlng);
        } else {
          marker = createMarker(e.latlng.lat, e.latlng.lng);
        }
        updateFormfields();
      };
      updateFormfields = function() {
        $(inputSelectors.lat).val(marker.getLatLng().lat);
        $(inputSelectors.long).val(marker.getLatLng().lng);
        $(inputSelectors.zoom).val(map.getZoom());
      };
      clearFormfields = function() {
        $(inputSelectors.lat).val("");
        $(inputSelectors.long).val("");
        $(inputSelectors.zoom).val("");
      };
      openMarkerPopup = function(e) {
        marker = e.target;
        $.ajax("/investments/" + marker.options.id + "/json_data", {
          type: "GET",
          dataType: "json",
          success: function(data) {
            e.target.bindPopup(getPopupContent(data)).openPopup();
          }
        });
      };
      getPopupContent = function(data) {
        return "<a href='/budgets/" + data.budget_id + "/investments/" + data.investment_id + "'>" + data.investment_title + "</a>";
      };
      map = App.Map.buildMap(element, center, zoom);
      if (App.Map.validCoordinates(markerCoordinates) && !addMarkerInvestments) {
        marker = createMarker(markerCoordinates.lat, markerCoordinates.long);
      }
      if (editable) {
        $(removeMarkerSelector).on("click", removeMarker);
        map.on("zoomend", function() {
          if (marker) {
            updateFormfields();
          }
        });
        map.on("click", moveOrPlaceMarker);
      }
      if (addMarkerInvestments) {
        addMarkerInvestments.forEach(function(coordinates) {
          if (App.Map.validCoordinates(coordinates)) {
            marker = createMarker(coordinates.lat, coordinates.long);
            marker.options.id = coordinates.investment_id;
            marker.on("click", openMarkerPopup);
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
    cleanInvestmentCoordinates: function(element) {
      var clean_markers, markers;
      markers = $(element).attr("data-marker-investments-coordinates");
      if (markers != null) {
        clean_markers = markers.replace(/-?(\*+)/g, null);
        $(element).attr("data-marker-investments-coordinates", clean_markers);
      }
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
