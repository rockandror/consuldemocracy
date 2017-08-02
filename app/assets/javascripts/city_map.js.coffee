App.CityMap =

  initialize: ->
    if $('#city-map').length > 0
      latLng = new (L.LatLng)($('#city-map').data('latitude'), $('#city-map').data('longitude'))
      zoom = $('#city-map').data('zoom')
      address = $('#city-map').data('address')
      map = L.map('city-map').setView(latLng, zoom)

      L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', attribution: '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributors').addTo map
      marker_el = document.getElementById('city-map-marker')
      marker_icon = L.divIcon(
        className: 'city-map-marker'
        iconSize: null
        html: marker_el.outerHTML)
      marker = L.marker(latLng, icon: marker_icon).addTo(map)

      onMapClick = (e) ->
        rellocateMarker e.latlng.lat, e.latlng.lng
        reCenterMap e.latlng.lat, e.latlng.lng
        updateFormfields e.latlng.lat, e.latlng.lng
        return

      reCenterMap = (lat, lng) ->
        coords = new (L.LatLng)(lat, lng)
        map.setView coords
        return

      rellocateMarker = (lat, lng) ->
        coords = new (L.LatLng)(lat, lng)
        marker.setLatLng coords
        return

      updateFormfields = (lat, lng) ->
        $('#' + $('#city-map').data('latitude-field-id')).val lat
        $('#' + $('#city-map').data('longitude-field-id')).val lng
        $('#' + $('#city-map').data('zoom-field-id')).val map.getZoom()
        return

      updateZoomField = (e) ->
        $('#' + $('#city-map').data('zoom-field-id')).val e.target.getZoom()
        reCenterMap(marker._latlng.lat, marker._latlng.lng)
        return

      autocomplete = ->
        field = $('#' + $('#city-map').data('address-field-id') + '.autocomplete')
        if $(field).length > 0
          src =  $('#city-map').data('geocode-url')
          $(field).autocomplete
            source: src
            minLength: 2
            select: ( event, ui ) ->
              event.preventDefault()
              console.log ui.item.data.display_name
              console.log ui.item.data.lat
              console.log ui.item.data.lon
              this.value = ui.item.data.display_name
              # $('#' + $('#city-map').data('address-field-id')).val ui.item.data.display_name
              $('#' + $('#city-map').data('latitude-field-id')).val ui.item.data.lat
              $('#' + $('#city-map').data('longitude-field-id')).val ui.item.data.lon

              reCenterMap ui.item.data.lat, ui.item.data.lon
              rellocateMarker ui.item.data.lat, ui.item.data.lon
              return

            create: ->
              $(this).data('ui-autocomplete')._renderItem = (ul, item) ->
                return $("<li>")
                  .append("<a>" + item.data.display_name  + "</a>")
                  .appendTo(ul);

      map.on 'click', onMapClick
      map.on 'zoomend', updateZoomField
      autocomplete()