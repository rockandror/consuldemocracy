namespace :padron do

    desc "Update users from Padron"
    task update: :environment do
        success = []# = 0
        failed = []
        User.all.each do |u|
            response = Padron.new.update_user(u.id)
            if response == true
                cont.push(u.id)
            else
                failed.push(u.id)
            end
        end
        puts "=================================================="
        puts "Usuarios actualizados:"
        succes.each do |s|
            puts s
        end
        puts "=================================================="
        puts "Usuarios fallidos:"
        failed.each do |f|
            puts f
        end
        puts "=================================================="
    end
  end