namespace :users do
  

  desc "Generate admin user"
  task admin: :environment do

    document_number ||= Rails.application.secrets.password_config.to_i
    document_number += 1
      
    pwd = Rails.application.secrets.password_config.to_s
    phone = "620070650"

    admin = User.create!(
      username:               "admin",
      email:                  "admin@madrid.es",
      phone_number:           phone,
      confirmed_phone:        phone,
      geozone_id:             Geozone.find_by(name: "Moratalaz").try(:id),
      password:               pwd,
      password_confirmation:  pwd,
      confirmed_at:           Time.current,
      terms_of_service:       "1",
      gender:                 ["Male", "Female"].sample,
      date_of_birth:          rand((Time.current - 80.years)..(Time.current - 16.years)),
      public_activity:        (rand(1..100) > 30)
    )
    
    
    admin.create_administrator
    admin.update(residence_verified_at: Time.current,
                 document_type: "1",
                 verified_at: Time.current, document_number: "#{document_number}#{[*"A".."Z"].sample}")
    admin.create_poll_officer
  end

  desc "Generate admin user"
  task update_admin: :environment do
    user = User.find_by(username: "admin")

    if !user.blank?
      if user.update(phone_number:  "620070650", confirmed_phone:  "620070650",geozone: Geozone.find_by(name: "Moratalaz"))
        puts "Se ha actualizado correctamente con el teléfono: #{ "620070650"}, y la geolocalización: #{Geozone.find_by(name: "Moratalaz").try(:name)}"
        admin=Administrator.new(user_id: user.id)
        
        if admin.save
          user.administrator = admin
          if user.save
            puts "se ha creado una instancia de administrador"
          end
        else
          puts "Error, no se ha creado el administrador: #{admin.errors.full_messages}"
          puts "Es administrador?: #{user.administrator?}"
        end
      else
        puts "Error, no se ha actualizado: #{user.errors.full_messages}"
      end

    else
      puts "Error: no se encuentra el usuario"
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
