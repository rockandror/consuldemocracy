namespace :map_borought do
    task add: :environment do
        boroughts = {
            "8" => ["Imperial", "Acacias", "Chopera", "Legazpi", "Delicias", "Palos de Moguer", "Atocha"], 
            "17" => ["Alameda de Osuna", "Aeropuerto", "Casco Histórico de Barajas", "Timón", "Corralejos"], 
            "7" => ["Comillas", "Opañel", "San Isidro", "Vista Alegre", "Puerta Bonita", "Buenavista", "Abrantes"], 
            "5" => ["Palacio", "Embajadores", "Cortes", "Justicia", "Universidad", "Sol "], 
            "11" => ["El Viso", "Prosperidad", "Ciudad Jardín", "Hispanoamérica", "Nueva España", "Castilla"],
            "4" => ["Gaztambide", "Arapiles", "Trafalgar", "Almagro", "Rios Rosas", "Vallehermoso"],
            "18" => ["Ventas", "Pueblo Nuevo", "Quintana", "Concepción", "San Pascual", "San Juan Bautista", "Colina", "Atalaya", "Costillares"],
            "1" => ["El Pardo", "Fuentelareina", "Peñagrande", "Pilar", "La Paz", "Valverde", "Mirasierra", "El Goloso"],
            "16" => ["Palomas", "Piovera", "Canillas", "Pinar del Rey", "Apostol Santiago", "Valdefuentes"],
            "6" => ["Cármenes", "Puerta del Angel", "Lucero", "Aluche", "Campamento", "Cuatro Vientos", "Aguilas"],
            "2" => ["Casa de Campo", "Argüelles", "Ciudad Universitaria", "Valdezarza", "Valdemarín", "El Plantío", "Aravaca"],
            "19" => ["Pavones", "Horcajo", "Marroquina", "Media Legua", "Fontarrón", "Vinateros"],
            "14" => ["Entrevías", "San Diego", "Palomeras Bajas", "Palomeras Sureste", "Portazgo", "Numancia"],
            "13" => ["Pacífico", "Adelfas", "Estrella", "Ibiza", "Jerónimos", "Niño Jesús"],
            "12" => ["Recoletos", "Goya", "Fuente del Berro", "Guindalera", "Lista", "Castellana"],
            "20" => ["Simancas", "Hellín", "Amposta", "Arcos", "Rosas", "Rejas", "Canillejas", "Salvador"], 
            "3" => ["Bellas Vistas", "Cuatro Caminos", "Castillejos", "Almenara", "Valdeacederas", "Berruguete"],
            "9" => ["Orcasitas", "Orcasur", "San Fermín", "Almendrales", "Moscardó", "Zofío", "Pradolongo"],
            "21" => ["Valderrivas", "Valdebernardo", "Casco histórico de Vicálvaro", "El Cañaveral"],
            "15" => ["Ensanche de Vallecas", "Casco Histórico de Vallecas", "Santa Eugenia"],
            "10" => ["Villaverde Alto", "Casco Histórico de Villaverde", "San Cristobal", "Butarque", "Los Rosales", "Los Angeles"]      
        }

        boroughts.each do |k,v|
            v.each do |d|
                proposal = Proposal.new(title: d, description: '', author_id: User.find_by(username: "admin_barrios").id, terms_of_service: "1", flags_count: "0", comments_count: "0", hot_score: "0",
                    confidence_score: 1, summary: d, video_url: '', geozone_id: k, published_at: Time.now, selected: false, skip_map: "1", comunity_hide: true)
                    if proposal.save
                    puts "Se ha añadido el barrio => #{d}"
                    else
                        puts "ERROR: #{proposal.errors.full_messages}"
                    end
            end
        end

    end

    task remove: :environment do
        count = 0
        Proposal.where(comunity_hide: true).each do |p|
            if p.comunity_hide == true
                if p.destroy 
                    count = count + 1
                end
            end
        end
        puts "Se han eliminado #{count} propuestas de barrios"
    end
end