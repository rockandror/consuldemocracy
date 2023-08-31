geozones = ["Adeje", "Arafo", "Arico", "Arona", "Buenavista del Norte", "Candelaria", "El Rosario",
            "El Sauzal", "El Tanque", "Fasnia", "Garachico", "Granadilla de Abona", "Guía de Isora",
            "Güimar", "Icod de los Vinos", "La Guancha", "La Laguna", "La Matanza de Acentejo", "La Orotava",
            "La Victoria de Acentejo", "Los Realejos", "Los Silos", "Puerto de La Cruz",
            "San Juan de La Rambla", "San Miguel de Abona", "Santa Cruz de Tenerife", "Santa Úrsula",
            "Santiago del Teide", "Tacoronte", "Tegueste", "Vilaflor"]

geozones.each { |geozone| Geozone.find_or_create_by!(name: geozone) }
