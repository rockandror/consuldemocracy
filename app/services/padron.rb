class Padron
    def update_user(id)
        if !id.blank?
            user = User.find(id)
            response = CensusApi.new.update_addres(user.document_type, user.document_number)
            return "No se han encontrado datos en Padron." if response.blank?
            if !user.adress.blank?

                user.adress.road_type = response[:sigla_via]
                user.adress.road_name = response[:nombre_via]
                user.adress.road_number = response[:numero_via]
                user.adress.floor = response[:planta]
                user.adress.door = response[:puerta]
                user.adress.gate = response[:portal]
                user.adress.district = response[:nombre_distrito]
                user.adress.borought = response[:nombre_barrio]
                user.adress.postal_code = response[:codigo_postal]

                if user.adress.save!
                    user.geozone_id = Geozone.find_by(code_district: response[:codigo_distrito].to_s).try(:code_district)
                    user.save
                    true
                else
                    return user.adress.errors.full_messages
                end
            else
                adress = Adress.new

                adress.road_type = response[:sigla_via]
                adress.road_name = response[:nombre_via]
                adress.road_number = response[:numero_via]
                adress.floor = response[:planta]
                adress.door = response[:puerta]
                adress.gate = response[:portal]
                adress.district = response[:nombre_distrito]
                adress.borought = response[:nombre_barrio]
                adress.postal_code = response[:codigo_postal]

                if adress.save!
                    user.adress = adress
                    user.save
                    true
                else
                    return adress.errors.full_messages
                end
            end
        else
            
        end
        
    end
end