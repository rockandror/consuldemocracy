namespace :models do
    task get: :environment do
       
        Dir.glob(Rails.root.join('app/models/*')).each do |x|
            if x.include?(".rb")
                model = "#{x}".gsub(".rb", '').gsub(Rails.root.join('app/models/').to_s, '').singularize.classify.constantize
                begin
                    if !model.try(:column_names).blank?
                        puts "=" *20
                        puts model
                        puts "*" *20
                        puts model.try(:column_names)
                        puts "=" *20
                    end
                rescue
                end

            end
        end
         
    end

end