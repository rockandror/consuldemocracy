App.Map =

  initialize: ->
    if $('#map').length > 0
      latLng = new (L.LatLng)($('#map').data('latitude'), $('#map').data('longitude'))
      zoom = $('#map').data('zoom')
      map = L.map('map').setView(latLng, zoom)

      L.tileLayer('//{s}.tile.osm.org/{z}/{x}/{y}.png', attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors').addTo map
      marker_el = document.getElementById('map-marker')
      marker_icon = L.divIcon(
        className: 'map-marker'
        iconSize: null
        html: marker_el.outerHTML)
      marker = L.marker(latLng, { icon: marker_icon, draggable: 'true' }).addTo(map)
      marker.on('dragend',  ->
        updateFormfields this.getLatLng().lat, this.getLatLng().lng
      )

      onMapClick = (e) ->
        marker.setLatLng(e.latlng)
        updateFormfields e.latlng.lat, e.latlng.lng
        return

      updateFormfields = (lat, lng) ->
        $('#' + $('#map').data('latitude-field-id')).val lat
        $('#' + $('#map').data('longitude-field-id')).val lng
        $('#' + $('#map').data('zoom-field-id')).val map.getZoom()
        return

      updateZoomField = (e) ->
        $('#' + $('#map').data('zoom-field-id')).val e.target.getZoom()
        return

      map.on 'click', onMapClick
      map.on 'zoomend', updateZoomField
