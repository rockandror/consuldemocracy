App.Map =

  initialize: ->
    maps = $("*[data-map]")

    if maps.length > 0
      $.each maps, (index, map) ->
        App.Map.initializeMap map

    $(".js-toggle-map").on
      click: ->
        App.Map.toggleMap()

  initializeMap: (element) ->
    App.Map.cleanInvestmentCoordinates(element)

    mapCenterLatitude        = $(element).data("map-center-latitude")
    mapCenterLongitude       = $(element).data("map-center-longitude")
    markerLatitude           = $(element).data("marker-latitude")
    markerLongitude          = $(element).data("marker-longitude")
    zoom                     = $(element).data("map-zoom")
    mapTilesProvider         = $(element).data("map-tiles-provider")
    mapAttribution           = $(element).data("map-tiles-provider-attribution")
    latitudeInputSelector    = $(element).data("latitude-input-selector")
    longitudeInputSelector   = $(element).data("longitude-input-selector")
    zoomInputSelector        = $(element).data("zoom-input-selector")
    removeMarkerSelector     = $(element).data("marker-remove-selector")
    addMarkerInvestments     = $(element).data("marker-investments-coordinates")
    addMarkerProposals       = $(element).data("marker-related-proposals-coordinates")
    relatedProposalsLayerText = $(element).data("related-proposals-layer-text")
    editable                 = $(element).data("marker-editable")
    marker                   = null
    markerIcon               = App.Map.createMarkerIcon(icon_related: false)
    markerRelatedIcon        = App.Map.createMarkerIcon(icon_related: true)

    createMarker = (latitude, longitude) ->
      markerLatLng  = new (L.LatLng)(latitude, longitude)
      marker  = L.marker(markerLatLng, { icon: markerIcon, draggable: editable })
      if editable
        marker.on "dragend", updateFormfields
      marker.addTo(map)
      return marker

    createRelatedMarker = (latitude, longitude) ->
      markerLatLng  = new (L.LatLng)(latitude, longitude)
      return L.marker(markerLatLng, { icon: markerRelatedIcon, zIndexOffset: "-1" })

    removeMarker = (e) ->
      e.preventDefault()
      if marker
        map.removeLayer(marker)
        marker = null
      clearFormfields()
      return

    moveOrPlaceMarker = (e) ->
      if marker
        marker.setLatLng(e.latlng)
      else
        marker = createMarker(e.latlng.lat, e.latlng.lng)

      updateFormfields()
      return

    updateFormfields = ->
      $(latitudeInputSelector).val marker.getLatLng().lat
      $(longitudeInputSelector).val marker.getLatLng().lng
      $(zoomInputSelector).val map.getZoom()
      return

    clearFormfields = ->
      $(latitudeInputSelector).val ""
      $(longitudeInputSelector).val ""
      $(zoomInputSelector).val ""
      return

    openMarkerPopup = (e) ->
      marker = e.target

      $.ajax "/investments/#{marker.options["id"]}/json_data",
        type: "GET"
        dataType: "json"
        success: (data) ->
          e.target.bindPopup(getPopupContent(data)).openPopup()

    getPopupContent = (data) ->
      content = "<a href='/budgets/#{data["budget_id"]}/investments/#{data["investment_id"]}'>#{data["investment_title"]}</a>"
      return content

    getProposalPopupContent = (url, title) ->
      return "<a href='#{url}'>#{title}</a>"

    mapCenterLatLng  = new (L.LatLng)(mapCenterLatitude, mapCenterLongitude)
    map              = L.map(element.id).setView(mapCenterLatLng, zoom)
    L.tileLayer(mapTilesProvider, attribution: mapAttribution).addTo(map)

    if markerLatitude && markerLongitude && !addMarkerInvestments
      marker  = createMarker(markerLatitude, markerLongitude)

    if editable
      $(removeMarkerSelector).on "click", removeMarker
      map.on    "zoomend", updateFormfields
      map.on    "click",   moveOrPlaceMarker

    if addMarkerInvestments
      addMarkerInvestments.forEach (coordinates) ->
        if App.Map.validCoordinates(coordinates)
          marker = createMarker(coordinates.lat, coordinates.long)
          marker.options["id"] = coordinates.investment_id

          marker.on "click", openMarkerPopup

    if addMarkerProposals
      relatedMarkers = L.layerGroup()
      addMarkerProposals.forEach (proposal_info) ->
        if App.Map.validCoordinates(proposal_info)
          marker = createRelatedMarker(proposal_info.lat, proposal_info.long)
          marker.bindPopup(getProposalPopupContent(proposal_info.url, proposal_info.title))
          relatedMarkers.addLayer(marker)

      App.Map.setupControlLayer(map, relatedMarkers, relatedProposalsLayerText)

  setupControlLayer: (map, relatedMarkers, text) ->
    relatedProposalsLayer = {}
    relatedIconLayer = ' <div class="layer-related-icon"></div>'
    relatedProposalsLayer[text+relatedIconLayer] = relatedMarkers
    L.control.layers(null, relatedProposalsLayer, { collapsed: false }).addTo(map)
    map.addLayer(relatedMarkers)

  toggleMap: ->
    $(".map").toggle()
    $(".js-location-map-remove-marker").toggle()

  cleanInvestmentCoordinates: (element) ->
    markers = $(element).attr("data-marker-investments-coordinates")
    if markers?
      clean_markers = markers.replace(/-?(\*+)/g, null)
      $(element).attr("data-marker-investments-coordinates", clean_markers)

  validCoordinates: (coordinates) ->
    App.Map.isNumeric(coordinates.lat) && App.Map.isNumeric(coordinates.long)

  isNumeric: (n) ->
    !isNaN(parseFloat(n)) && isFinite(n)

  createMarkerIcon: (marker_option) ->
    relatedIconClass = "map-icon-related" if marker_option.icon_related
    L.divIcon(
      className: "map-marker"
      iconSize:     [30, 30]
      iconAnchor:   [15, 40]
      html: "<div class='map-icon #{relatedIconClass}'></div>"
    )
