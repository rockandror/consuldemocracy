# Nominatim response stub http://wiki.openstreetmap.org/wiki/Nominatim
Geocoder::Lookup::Test.add_stub(
  "Madrid", [
    {
      "lat"=>"40.42218175",
      "lon"=>"-3.69051460462006",
      "display_name"=>"Área metropolitana de Madrid y Corredor del Henares, Community of Madrid, Spain",
    },
    {
      "lat"=>"40.5248319",
      "lon"=>"-3.77156277545181",
      "display_name"=>"Community of Madrid, Spain",
    }
  ]
)