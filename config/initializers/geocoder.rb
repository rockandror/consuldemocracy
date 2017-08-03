if Rails.env.test?

  Geocoder.configure(:lookup => :test)

else
  Geocoder.configure(

    # geocoding service (see below for supported options):
    :lookup => :nominatim,

    # IP address geocoding service (see below for supported options):
    :ip_lookup => :maxmind,

    # to use an API key:
    :api_key => "...",

    # geocoding service request timeout, in seconds (default 3):
    :timeout => 5,

    # set default units to kilometers:
    :units => :km,

    # caching (see below for details):
    # :cache => Redis.new,
    # :cache_prefix => "...",

    # https://github.com/alexreisner/geocoder#nominatim-nominatim
    :http_headers => { "User-Agent" => "your contact info" }
  )
end