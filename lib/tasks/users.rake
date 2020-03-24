namespace :users do
  

  desc "Generate admin user"
  task admin: :environment do

    document_number ||= Rails.application.secrets.password_config.to_i
    document_number += 1
      
    pwd = Rails.application.secrets.password_config.to_s
    phones = Rails.application.secrets.phones_config
    emails = Rails.application.secrets.emails_config
    usernames = Rails.application.secrets.usernames_config
    districts = Rails.application.secrets.districts_config
 
    (0..phones.count-1).each do |i|
     begin
        puts "============================================="
        
        exist = User.find_by(username: usernames[i])

        if exist.blank?
          admin = User.create!(
            username:               usernames[i],
            email:                  emails[i],
            phone_number:           phones[i],
            confirmed_phone:        phones[i],
            geozone_id:             Geozone.find_by(name: districts[i]).try(:id),
            password:               pwd,
            password_confirmation:  pwd,
            confirmed_at:           Time.current,
            terms_of_service:       "1",
            gender:                 ["Male", "Female"].sample,
            date_of_birth:          rand((Time.current - 80.years)..(Time.current - 16.years)),
            public_activity:        (rand(1..100) > 30)
          )
          
          
          admin.create_administrator
          admin.update(residence_verified_at: Time.current, document_type: "1",
                      verified_at: Time.current, document_number: "#{document_number}#{[*"A".."Z"].sample}")
          admin.create_poll_officer
        else 
          if exist.update( password:  pwd, password_confirmation:  pwd, phone_number:  phones[i], confirmed_phone:  phones[i],geozone: Geozone.find_by(name: districts[i]))
            puts "Se ha actualizado correctamente con el teléfono: #{ phones[i]}, y la geolocalización: #{Geozone.find_by(name: districts[i]).try(:name)}"
            admin=Administrator.new(user_id: exist.id)
            
            if admin.save
              exist.administrator = admin
              if exist.save
                puts "se ha creado una instancia de administrador"
              end
            else
              puts "Error, no se ha creado el administrador: #{admin.errors.full_messages}"
              puts "Es administrador?: #{exist.administrator?}"
            end
          else
            puts "Error, no se ha actualizado: #{exist.errors.full_messages}"
          end
        end
        puts "Se ha generado el administrador: #{emails[i]}"
        puts "============================================="
      rescue => error
        puts "-----------------------------------------------------------"
        puts "ERROR: No se ha podido crear el administrador: #{emails[i]}"
        puts error
        puts "-----------------------------------------------------------"
        
      end
    end
  end

  desc "Generate admin user"
  task update_admin: :environment do
    Rails.application.secrets.users_change_config.each do |user|
        aux_user = JSON.parse(user)
        puts "========================================================="
        if !aux_user["email"].blank?
          puts "Accedo con email: #{aux_user["email"]}"
          user = User.find_by(email: aux_user["email"])

        elsif !aux_user["username"].blank?
          puts "Accedo con username: #{aux_user["username"]}"
          user = User.find_by(username: aux_user["username"])
        else
          user = nil
        end

        if !user.blank?
        puts "Documento anterior #{user.try(:document_number)}"
        document_number_aux ||= Rails.application.secrets.password_config.to_i
        document_number_aux += 1
        document_type =  user.document_type.blank? ? "1" :  user.document_type
        document_number = user.document_number.blank? ? "#{document_number_aux}#{[*"A".."Z"].sample}" :  user.document_number

          if user.update(residence_verified_at: Time.current, verified_at: Time.current, document_type: document_type, document_number: document_number)
            puts "Documento nuevo #{user.try(:document_number)}"
            puts "Se ha verificado el usuario"
          end
          if !aux_user["phone"].blank?
            if user.update(phone_number: aux_user["phone"], confirmed_phone: aux_user["phone"])
              puts "Se ha actualizado correctamente el teléfono del usuario: #{user.email} (#{user.phone_number}) "
            else
              puts "ERROR: no se ha podido actualizar el teléfono de #{user.email}: #{user.errors.full_messages}"
            end
          end

          if !aux_user["pwd"].blank?
            if user.update(password: aux_user["pwd"], password_confirmation: aux_user["pwd"])
              puts "Se ha actualizado correctamente la contraseña del usuario: #{user.email}"
            else
              puts "ERROR: no se ha podido actualizar la contraseña de #{user.email}: #{user.errors.full_messages}"
            end
          end

          if !aux_user["admin"].blank?
            admin=Administrator.new(user_id: user.id)
            if admin.save
              user.administrator = admin
              if user.save
                puts "Se ha creado una instancia de administrador para #{user.email}"
              end
            else
              puts "ERROR: no se ha creado la instancia de administrador: #{admin.errors.full_messages}"
              puts "Es administrador?: #{user.administrator?}"
            end
          end
        else
          puts "ERROR: no se encuentra el usuario: #{aux_user["email"]}#{aux_user["username"]}"
        end
        puts "========================================================="
    end
  end


  desc "Borrado de usuarios particulares"
  task delete: :environment do
    emails = ["cristina.ruiz@ericsson.com", "juanjocid.agviajes@hotmail.es"]

    User.where("email in (?)",emails).each do |user|
      puts "==========================="
      puts user.id
      puts user.email
      puts "==========================="
      if user.destroy
        puts "Se ha eliminado correctamente"
      else
        puts user.errors.full_messages
      end
    end
  end

  desc "Recalculates all the failed census calls counters for users"
  task count_failed_census_calls: :environment do
    User.find_each { |user| User.reset_counters(user.id, :failed_census_calls) }
  end

  desc "Associates a geozone to each user who doesn't have it already but has validated his residence using the census API"
  task assign_geozones: :environment do
    User.residence_verified.where(geozone_id: nil).find_each do |u|
      begin
        response = CensusApi.new.call(u.document_type, u.document_number)
        if response.valid?
          u.geozone = Geozone.where(census_code: response.district_code).first
          u.save
          print "."
        else
          print "X"
        end
      rescue
        puts "Could not assign geozone for user: #{u.id}"
      end
    end
  end

  desc "Associates demographic information to users"
  task assign_demographic: :environment do
    User.residence_verified.where(gender: nil).find_each do |u|
      begin
        response = CensusApi.new.call(u.document_type, u.document_number)
        if response.valid?
          u.gender = response.gender
          u.date_of_birth = response.date_of_birth.to_datetime
          u.save
          print "."
        else
          print "X"
        end
      rescue
        puts "Could not assign gender/dob for user: #{u.id}"
      end
    end
  end

  desc "Updates document_number with the ones returned by the Census API, if they exist"
  task assign_census_document_number: :environment do
    User.residence_verified.order(id: :desc).find_each do |u|
      begin
        response = CensusApi.new.call(u.document_type, u.document_number)
        if response.valid?
          u.document_number = response.document_number
          if u.save
            print "."
          else
            print "\n\nUpdate error for user: #{u.id}. Old doc:#{u.document_number_was}, new doc: #{u.document_number}. Errors: #{u.errors.full_messages} \n\n"
          end
        else
          print "X"
        end
      rescue StandardError => e
        print "\n\nError for user: #{u.id} - #{e} \n\n"
      end
    end
  end

end
