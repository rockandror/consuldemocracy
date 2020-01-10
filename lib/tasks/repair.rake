namespace :repair do

    desc "Reparar imagenes"
    task images: :environment do
        image_x = Image.find(881)

        puts image_x.attachment
        image_x.attachment_file_name = "#{image_x.title}.jpg"  #"#{image_x.title}.jpg"
        if image_x.save
            puts "Se ha guardado"
            puts image_x.attachment
        else
            puts "No se ha guardado"
        end
    end

end