namespace :geozone do
    task add_code: :environment do
        [
            ["Fuencarral - El Pardo","08"],
            ["Moncloa - Aravaca","09"],
            ["Tetuán","06"],
            ["Chamberí","07"],
            ["Centro","01"],
            ["Latina","10"],
            ["Carabanchel","11"],
            ["Arganzuela","02"],
            ["Usera","12"],
            ["Villaverde","17"],
            ["Chamartín","05"],
            ["Salamanca","04"],
            ["Retiro","03"],
            ["Puente de Vallecas","13"],
            ["Villa de Vallecas","18"],
            ["Hortaleza","16"],
            ["Barajas","21"],
            ["Ciudad Lineal","15"],
            ["Moratalaz","14"],
            ["San Blas-Canillejas","20"],
            ["Vicálvaro","19"]].each do |dname|
            geozone = Geozone.find_by(name: dname[0])
            geozone.code_district = dname[1]
            if geozone.save
                puts "Se ha guardado correctamente la geozona #{dname[0]}"
            else
                puts "ERROR: No se ha guardado correctamente la geozona #{dname[0]}"
            end
        end

    end

end