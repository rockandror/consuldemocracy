namespace :users do
  desc "Actualización de datos DEMAD-106"
  task update_106: :environment do
    #RAKE temporal
    puts "==========================================================================="
    puts "Cambio de geozona usuario: 72351"
    puts "==========================================================================="
    user = User.find_by(id: 72351)

    if !user.blank?
      user.geozone = Geozone.find_by(name: "Moncloa-Aravaca")
      if user.save
        puts "Se ha guardado correctamente la geozona: #{user.id} (#{user.geozone.name})"
      else
        puts "ERROR: no se ha podido guardar la geozona: #{user.errors.full_messages}"
      end
    else
      puts "No se ha encontrado el usuario con id: 72351"
    end
    puts "==========================================================================="
    puts
    puts "==========================================================================="
    puts "Actualización de contraseña usuario: 278975"
    puts "==========================================================================="
    pwd = (0...20).map { ("a".."z").to_a[rand(26)] }.join
    user = User.find_by(id: 278975)

    if !user.blank?
      user.password = pwd
      user.password_confirmation = pwd
      if user.save
        puts "Se ha guardado correctamente la contraseña: #{user.id} (#{pwd})"
      else
        puts "ERROR: no se ha podido guardar la contraseña: #{user.errors.full_messages}"
      end
    else
      puts "No se ha encontrado el usuario con id: 278975"
    end
    puts "==========================================================================="
  end

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
          admin.update(residence_verified_at: Time.current, document_type: "1", confirmed_at:Time.current,
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
          ActiveRecord::Base.connection.execute("UPDATE users SET hidden_at=NULL WHERE email='#{aux_user["email"]}'") if aux_user["no_admin"].blank?
          user = User.find_by(email: aux_user["email"])

        elsif !aux_user["username"].blank?
          puts "Accedo con username: #{aux_user["username"]}"
          ActiveRecord::Base.connection.execute("UPDATE users SET hidden_at=NULL WHERE username='#{aux_user["username"]}'") if aux_user["no_admin"].blank?
          user = User.find_by(username: aux_user["username"])
        else
          user = nil
        end

        if !user.blank?
          if aux_user["no_admin"] 
            if user.destroy
              puts "Usuario bloqueado"
            else
              puts "El usuario no se ha podido bloquear: #{user.errors.full_messages}"
            end
          else
            puts "Documento anterior #{user.try(:document_number)}"
            document_number_aux ||= Rails.application.secrets.password_config.to_i
            document_number_aux += 1
            document_type =  user.document_type.blank? ? "1" :  user.document_type
            document_number = user.document_number.blank? ? "#{document_number_aux}#{[*"A".."Z"].sample}" :  user.document_number
            lock = Lock.find_by(user_id: user.id)
            if !lock.blank?
              if lock.destroy
                puts "Usuario desbloqueado"
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

            if user.update(residence_verified_at: Time.current, confirmed_at:Time.current, verified_at: Time.current, 
              document_type: document_type, document_number: document_number, confirmed_hide_at: nil, locked_at: nil,
              access_key_tried: 0, access_key_generated_at: Time.current, access_key_generated:  "ABCD", access_key_inserted: "ABCD")
              puts "Documento nuevo #{user.try(:document_number)}"
              puts "Se ha verificado el usuario"
              puts "El usuario puede acceder sin código?: #{user.access_key_inserted.to_s == user.access_key_generated.to_s && user.try(:administrator?)}"
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
          end

         
        else
          document_number ||= Rails.application.secrets.password_config.to_i
          document_number += 1
            
          pwd = Rails.application.secrets.password_config.to_s
          puts "ERROR: no se encuentra el usuario: #{aux_user["email"]}#{aux_user["username"]}"
          if aux_user["no_admin"].blank?
            admin = User.create!(
              username:               aux_user["username"] || aux_user["email"].gsub(/@.*/,''),
              email:                  aux_user["email"] || "sample@sample.es",
              phone_number:           aux_user["phone"],
              confirmed_phone:        aux_user["phone"],
              geozone_id:             Geozone.find_by(name: "Salamanca").try(:id),
              password:               pwd,
              password_confirmation:  pwd,
              confirmed_at:           Time.current,
              terms_of_service:       "1",
              gender:                 ["Male", "Female"].sample,
              date_of_birth:          rand((Time.current - 80.years)..(Time.current - 16.years)),
              public_activity:        (rand(1..100) > 30)
            )
            
            
            admin.create_administrator
            if admin.update(residence_verified_at: Time.current, document_type: "1", confirmed_at:Time.current,
                        verified_at: Time.current, document_number: "#{document_number}#{[*"A".."Z"].sample}")
              puts "Se ha creado el adminsitrador: #{aux_user["email"]}#{aux_user["username"]}"
            end
          end
        end
        puts "========================================================="
    end
  end


  desc "Borrado de usuarios particulares"
  task delete: :environment do
    emails = ["pelaezrmp@madrid.es"]

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

  desc "Add phone number to user"
  task phone_number: :environment do
    user = User.find_by(email: "taranconmr@madrid.es")
    if !user.blank?
      user.confirmed_phone = "669660678"
      user.save
      puts "==============================="
      puts "Telefono añadido al usuario => #{user.id}"
      puts "==============================="
    else
      puts "==============================="
      puts "Usuario no encontrado"
      puts "==============================="
    end
  end

  desc "delete user"
  task delete_user_prueba: :environment do
  
      user = User.find(186929)
      user.username = "Usuario dado de baja-" + user.id.to_s
      user.date_hide = Date.today
      user.email = "#{user.id}@nomail.com"
      user.document_number = nil
      user.confirmed_phone = nil
      user.gender = nil
    if user.save!
      puts "Usuario eliminado el #{user.date_hide}"
    else
      puts "ERROR: #{user.errors.full_messages}"
    end
  
  end
  desc "change user's district"
  task change_district: :environment do
    user = User.find_by(document_number: "44510002B")
    user.geozone_id = "15"
    if user.save!
      puts "Se ha cambiado el distrito del usuario '#{user.username}' por: #{user.geozone_id}"
    else
      puts "ERROR: #{user.errors.full_messages}"
    end
  end

  desc "delete user activity"
  task delete_activity: :environment do
    user = User.find_by(document_number: "46152852V")
    begin
      ActiveRecord::Base.transaction do
        Administrator.where(user_id: user.id).each do |admin|
          admin.destroy
        end
        Proposal.where(author_id: user.id).each do |proposal|
          proposal.destroy
        end
        Debate.where(author_id: user.id).each do |debate|
          debate.destroy
        end
        Activity.where(user_id: user.id).each do |activity|
          activity.destroy
        end
        Budget::Investment.where(author_id: user.id).each do |b_i|
          b_i.destroy
        end
        Comment.where(user_id: user.id).each do |comment|
          comment.destroy
        end
        FailedCensusCall.where(user_id: user.id).each do |call|
          call.destroy
        end
        Valuator.where(user_id: user.id).each do |valuator|
          valuator.destroy
        end
        DirectMessage.where(sender_id: user.id).each do |dm|
          dm.destroy
        end
        DirectMessage.where(receiver_id: user.id).each do |dm|
          dm.destroy
        end
        Moderator.where(user_id: user.id).each do |valuator|
          valuator.destroy
        end
        Legislation::Answer.where(user_id: user.id).each do |legis|
          legis.destroy
        end
        Manager.where(user_id: user.id).each do |valuator|
          valuator.destroy
        end
        Organization.where(user_id: user.id).each do |org|
          org.destroy
        end
        Follow.where(user_id: user.id).each do |follow|
          follow.destroy
        end
        Lock.where(user_id: user.id).each do |lock|
          lock.destroy
        end
        Image.where(user_id: user.id).each do |image|
          image.destroy
        end
        Flag.where(user_id: user.id).each do |flag|
          flag.destroy
        end
        Notification.where(user_id: user.id).each do |notification|
          notification.destroy
        end
        Identity.where(user_id: user.id).each do |identity|
          identity.destroy
        end
        RelatedContentScore.where(user_id: user.id).each do |related|
          related.destroy
        end
        Document.where(user_id: user.id).each do |doc|
          doc.destroy
        end
        Dashboard::AdministratorTask.where(user_id: user.id).each do |dash|
          dash.destroy
        end
        Poll::Question.where(author_id: user.id).each do |poll|
          poll_question_answers = "delete from poll_question_answers where question_id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_question_answers)
          poll_partial_results = "delete from poll_partial_results where question_id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_partial_results)
          poll_answers = "delete from poll_answers where question_id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_answers)
          poll_questions = "delete from poll_questions where id = #{poll.id}"
          ActiveRecord::Base.connection.execute(poll_questions)
        end
        Poll::Officer.where(user_id: user.id).each do |poll|
          poll.destroy
        end
        
        puts "==================================================="
        puts "Se ha borrado toda la actividad del usuario: #{user.id}"
        puts "==================================================="
      end
    rescue
      puts "====================================================="
      puts "No se ha podido borrar la actividad del usuario: #{user.id}"
      puts "====================================================="
    end
  end

  desc "create user profiles"
  task create_profiles: :environment do
    [["Super Administrador", 1], ["Administrador", 2], ["Administrador Sures",3], ["Administrador Sectorial",4], ["Gestor",5], ["Moderador", 6], ["Evaluador", 7], ["Consultor", 8], ["Editor", 9]].each do |p|
      profile = Profile.find_by(name: p[0].to_s)

      if !profile.blank?
        profile.name = p[0].to_s
        profile.code = p[1].to_s
      else      
        profile = Profile.new(name: p[0].to_s, code: p[1].to_s )
      end
      if profile.save
        puts "Perfil #{profile.name} creado/actualizado."
      else
        puts "--------------------------------------------"
        puts "No se ha podido crear el perfil #{p}."
        puts profile.errors.full_messages
        puts "--------------------------------------------"
      end
    end
  end

  desc "create new users roles"
  task new_roles: :environment do

    @user = User.new(username: "admin_sectorial", email: "admin_sectorial@madrid.com", document_type: "1", document_number: "70898770T", profiles_id: 4)
    @user.terms_of_service = "1"
    @user.verified_at = Time.current
    @user.confirmed_at = Time.current
    @user.password = "12345678"
    @user.password_confirmation = "12345678"
    @user.geozone_id = 17

    profile = SectionAdministrator.new
    profile.user = @user
    profile.save

    if @user.save!
      puts "="*40
      puts "Administrador sectorial creado"
      puts "="*40
    else
      puts "="*40
      puts @user.errors.full_messages
      puts "="*40
    end

    @user = User.new(username: "gestor", email: "gestor@madrid.com", document_type: "1", document_number: "70898870T", profiles_id: 5)
    @user.terms_of_service = "1"
    @user.verified_at = Time.current
    @user.confirmed_at = Time.current
    @user.password = "12345678"
    @user.password_confirmation = "12345678"
    @user.geozone_id = 17

    profile = Manager.new
    profile.user = @user
    profile.save

    if @user.save!
      puts "="*40
      puts "Gestor creado"
      puts "="*40
    else
      puts "="*40
      puts @user.errors.full_messages
      puts "="*40
    end

    @user = User.new(username: "consultor", email: "consultor@madrid.com", document_type: "1", document_number: "70898970T", profiles_id: 8)
    @user.terms_of_service = "1"
    @user.verified_at = Time.current
    @user.confirmed_at = Time.current
    @user.password = "12345678"
    @user.password_confirmation = "12345678"
    @user.geozone_id = 17

    profile = Consultant.new
    profile.user = @user
    profile.save

    if @user.save!
      puts "="*40
      puts "Consultor creado"
      puts "="*40
    else
      puts "="*40
      puts @user.errors.full_messages
      puts "="*40
    end
  end
end
