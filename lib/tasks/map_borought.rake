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
            "10" => ["Villaverde Alto. Casco Histórico de Villaverde", "San Cristobal", "Butarque", "Los Rosales", "Los Angeles"]      
        }
        count = 0
        total = 0
        boroughts.each do |k,v|
            v.each do |d|
                total = total + 1
                proposal = Proposal.new(title: d, description: '', author_id: User.find_by(username: "admin_barrios").try(:id), terms_of_service: "1", flags_count: "0", comments_count: "0", hot_score: "0",
                    confidence_score: 1, summary: d, video_url: '', geozone_id: k, published_at: Time.now, selected: false, skip_map: "1", comunity_hide: true)
                    if proposal.save
                        count = count + 1
                        puts "Se han añadido el barrio => #{d}"
                    else
                        puts "ERROR: #{proposal.errors.full_messages}"
                    end
            end
        end
        puts "Se han añadido #{count}/#{total}"
    end
    task coords: :environment do
        coords = { 
            "Imperial" => ["40.40574342951", "-3.71882915496826"], "Acacias" => ["40.4009623379666", "-3.70708107948303"],
            "Chopera" => ["40.3951938570271", "-3.6994206905365"], "Legazpi" => ["40.3888512257702", "-3.68773698806763"],
            "Delicias" => ["40.3969260873622", "-3.6900007724762"], "Palos de Moguer" => ["40.4041143669155", "-3.69464635848999"],
            "Atocha" => ["40.4004214616447", "-3.68207216262817"], "Alameda de Osuna" => ["40.4572632068469", "-3.58946084976196"], 
            "Aeropuerto" => ["40.4509933724717", "-3.58319520950317"], "Casco Histórico de Barajas" => ["40.4735408183791", "-3.57951521873474"], 
            "Timón" => ["40.4721843653044", "-3.58907461166382"], "Corralejos" => ["40.4654914766043", "-3.59122037887573"],
            "Comillas" => ["40.3929549650081", "-3.71175885200501"], "Opañel" => ["40.3907977139611", "-3.72122168540955"],
            "San Isidro" => ["40.3946039079326","-3.72876405715942"], "Vista Alegre" => ["40.3887874860139","-3.74001860618591"],
            "Puerta Bonita" => ["40.3801558985419","-3.73713254928589"], "Buenavista" => ["40.3685494839125", "-3.74421358108521"],
            "Abrantes" => ["40.3810058672399", "-3.7279486656189"], "Palacio" => ["40.4153895465148", "-3.71467709541321"],
            "Embajadores" => ["40.4095732863873","-3.70347619056702"], "Cortes" => ["40.4148014082261", "-3.69753241539002"],
            "Justicia" => ["40.4233289102471","-3.69660973548889"], "Universidad" => ["40.4254687841913", "-3.70605111122131"], 
            "Sol " => ["40.4173336337195", "-3.70448470115662"], "El Viso" => ["40.445018525137","-3.68472218513489"],
            "Prosperidad" => ["40.4440060632701", "-3.67013096809387"], "Ciudad Jardín" => ["40.4487400078415","-3.67366075515747"],
            "Hispanoamérica" => ["40.455369256051","-3.67713689804077"], "Nueva España" => ["40.4627488320033","-3.67868185043335"],
            "Castilla" => ["40.4764609351205","-3.67992639541626"], "Gaztambide" => ["40.4350238790188","-3.71472001075745"],
            "Arapiles" => ["40.4348278907123","-3.70826125144959"], "Trafalgar" => ["40.4331129686627","-3.70103001594544"],
            "Almagro" => ["40.4336356162066","-3.69424939155579"], "Rios Rosas" => ["40.4426506468975","-3.69761824607849"],
            "Vallehermoso" => ["40.4432385416926","-3.7105143070221"], "Ventas" => ["40.4220547544961","-3.65172028541565"],
            "Pueblo Nuevo" => ["40.4264635572719","-3.63563776016235"], "Quintana" => ["40.4357082002761","-3.64709615707398"],
            "Concepción" => ["40.4382233072361","-3.64954233169556"], "San Pascual" => ["40.442795987934","-3.65344762802124"],
            "San Juan Bautista" => ["40.4507500781447","-3.65631222724915"], "Colina" => ["40.4581122019421","-3.6603569984436"],
            "Atalaya" => ["40.4644466728181","-3.66520643234253"], "Costillares" => ["40.4761671336942","-3.66846799850464"],
            "El Pardo" => ["40.520632399975","-3.77799868583679"], "Fuentelareina" => ["40.4776034840012","-3.74253988265991"],
            "Peñagrande" => ["40.4790071612902","-3.72575998306274"], "Pilar" => ["40.4772443993053","-3.7088942527771"],
            "La Paz" => ["40.4812595107546","-3.69649171829224"], "Valverde" => ["40.4980028688162","-3.6799693107605"], 
            "Mirasierra" => ["40.4907903549588","-3.71618986129761"], "El Goloso" => ["40.5575661865771","-3.71391534805298"], 
            "Palomas" => ["40.4522996362117","-3.61396551132202"], "Piovera" => ["40.4554998750613","-3.63585233688355"],
            "Canillas" => ["40.4619978502618","-3.64327669143677"], "Pinar del Rey" => ["40.4678748744149","-3.64859819412231"],
            "Apostol Santiago" => ["40.4770485341162","-3.66155862808228"], "Valdefuentes" => ["40.4931075819472","-3.63499402999878"],
            "Cármenes" => ["40.4003887801627","-3.73271226882935"], "Puerta del Angel" => ["40.4136561574297","-3.72713327407837"],
            "Lucero"=> ["40.4045898546975","-3.74523282051086"], "Aluche"=> ["40.3880667310369","-3.75472784042358"],
            "Campamento"=> ["40.3841408511668","-3.78637790679932"], "Cuatro Vientos"=> ["40.3710997970858","-3.77258062362671"],
            "Aguilas"=> ["40.3813654661531","-3.78021955490112"], "Casa de Campo" => ["40.4240688889262","-3.75277519226074"],
            "Argüelles" => ["40.4285216619699","-3.71747732162476"], "Ciudad Universitaria" => ["40.4466172039324","-3.72623205184937"],
            "Valdezarza" => ["40.4649690767427","-3.71683359146118"], "Valdemarín" => ["40.4682340092182","-3.77743005752564"],
            "El Plantío" => ["40.470842575999","-3.82208347320557"], "Aravaca" => ["40.4578477082675","-3.7827730178833"],
            "Pavones" => ["40.399735147192","-3.63156080245972"], "Horcajo" => ["40.4081665254091","-3.62671136856079"],
            "Marroquina" => ["40.4107169727473","-3.64058375358582"], "Media Legua" => ["40.4119897093321","-3.65756750106812"],
            "Fontarrón" => ["40.4065505931609","-3.65835070610046"], "Vinateros" => ["40.4101287936182","-3.6525571346283"],
            "Entrevías" => ["40.3791424603096","-3.67164373397827"], "San Diego" => ["40.3923159682031","-3.66743803024292"],
            "Palomeras Bajas" => ["40.3855186945809","-3.65796446800232"], "Palomeras Sureste" => ["40.3865304023813","-3.63280534744263"],
            "Portazgo" => ["40.3914334563897","-3.64808320999146"], "Numancia" => ["40.3995063741529","-3.65967035293579"],
            "Pacífico" => ["40.4052107613906","-3.67667555809021"], "Adelfas" => ["40.4019427671706","-3.6708390712738"],
            "Estrella" => ["40.4118116257729","-3.66697669029236"], "Ibiza" => ["40.4189999494717","-3.67371439933777"],
            "Jerónimos" => ["40.4132313804611","-3.68430376052856"], "Niño Jesús" => ["40.4116956259722","-3.67331743240356 "],
            "Recoletos" => ["40.424438059415","-3.68563413619995"], "Goya" => ["40.4250587829821","-3.67426156997681"],
            "Fuente del Berro" => ["40.4253528079356","-3.66357564926148"], "Guindalera" => ["40.4364268118652","-3.66799592971802"],
            "Lista" => ["40.4327356798426","-3.67439031600952"], "Castellana" => ["40.4334543232003","-3.68396043777466"],
            "Simancas" => ["40.4376353685808","-3.62478017807007"], "Hellín" => ["40.4310370377394","-3.61872911453247"],
            "Amposta" => ["40.4250914524848","-3.62430810928345"], "Arcos" => ["40.4213996982646","-3.6184287071228"],
            "Rosas" => ["40.4257791419349","-3.60067248344421"], "Rejas" => ["40.4449189125301","-3.57190847396851"],
            "Canillejas" => ["40.4474010162606","-3.60838651657105"], "Salvador" => ["40.4449368755518","-3.63161444664002"],
            "Bellas Vistas" => ["40.4528547906122","-3.70700597763062"], "Cuatro Caminos" => ["40.4518751032814","-3.69760751724243 "],
            "Castillejos" => ["40.4599081177534","-3.69395971298218"], "Almenara" => ["40.470160244934","-3.69370222091675"],
            "Valdeacederas" => ["40.4679091556469","-3.7034547328949"], "Berruguete" => ["40.4603015802694","-3.7043559551239"],
            "Orcasitas" => ["40.3691707229355","-3.70966672897339"], "Orcasur" => ["40.3681244223342","-3.70074033737183"],
            "San Fermín" => ["40.3711504755079","-3.69010806083679"], "Almendrales" => ["40.3844236139767","-3.69933485984802"],
            "Moscardó" => ["40.3890980134474","-3.70568633079529"], "Zofío" => ["40.3792748620765","-3.71525645256043"],
            "Pradolongo" => ["40.3766921653108","-3.70778918266296"], "Valderrivas" => ["40.3979703064721","-3.60491037368774"],
            "Valdebernardo" => ["40.3964309352046","-3.61583232879639"], "Casco histórico de Vicálvaro" => ["40.4057777419371","-3.60750675201416"],
            "El Cañaveral" => ["40.4043104447172","-3.54628801345825"], "Ensanche de Vallecas" => ["40.3673364162712","-3.59918117523193"],
            "Casco Histórico de Vallecas" => ["40.3776713141662","-3.6219048500061"], "Santa Eugenia" => ["40.3829672925378","-3.61169099807739"],
            "Villaverde Alto. Casco Histórico de Villaverde" => ["40.3414709791879","-3.71116876602173"],
            "San Cristobal" => ["40.3408494849091","-3.6880373954773"], "Butarque" => ["40.3364007271187","-3.67421865463257"],
            "Los Rosales" => ["40.3573956342332","-3.68956089019775"], "Los Angeles" => ["40.3564145585343","-3.69934558868408"]
        }

        count = 0    
        coords.each do |k,v|
            
            location = MapLocation.new(latitude: v[0].to_s, longitude: v[1].to_s, zoom: 16, proposal_id: Proposal.find_by(title: k.to_s).id)
            if location.save!
                count = count + 1
                puts "Se ha añadido la localización de #{k.to_s}"
            else
                puts "ERROR: #{proposal.errors.full_messages}"
            end
            
        end
        puts "Se han añadido #{count}/#{coords.count} localizaciones de barrios."
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

    task remove_borought: :environment do
        delete_proposals = "delete from proposals where title = 'Villaverde Alto'"
        ActiveRecord::Base.connection.execute(delete_proposals)
        puts "Se ha eliminado Villaverde Alto de las propuestas de barrios" 
    end

    task change_borought: :environment do
        borought = Proposal.find_by(title: "Casco Histórico de Villaverde")
        borought.title = "Villaverde Alto. Casco Histórico de Villaverde"
        if borought.save!
            puts "Se ha cambiado el nombre por #{borought.title}"
        else
            puts "ERROR: #{borought.errors.full_messages}"
        end
    end
end