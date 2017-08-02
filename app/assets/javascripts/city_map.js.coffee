App.CityMap =

  initialize: ->
    latLng = new (L.LatLng)($('#city-map').data('latitude'), $('#city-map').data('longitude'))
    zoom = $('#city-map').data('zoom')
    address = $('#city-map').data('address')
    map = L.map('city-map').setView(latLng, zoom)

    onMapClick = (e) ->
      marker.setLatLng e.latlng
      reCenterMap e
      updateForfields e.latlng
      return

    reCenterMap = (e) ->
      map.setView e.latlng
      return

    updateForfields = (latLng) ->
      $('#' + $('#city-map').data('latitude-field-id')).val latLng.lat
      $('#' + $('#city-map').data('longitude-field-id')).val latLng.lng
      $('#' + $('#city-map').data('zoom-field-id')).val map.getZoom()
      return

    L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors').addTo map
    marker_el = document.getElementById('city-map-marker')
    marker_icon = L.divIcon(
      className: 'city-map-marker'
      iconSize: null
      html: marker_el.outerHTML)
    marker = L.marker(latLng, icon: marker_icon).addTo(map)

    map.on 'click', onMapClick