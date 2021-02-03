require 'csv'
 
# Read more about this here: http://technicalpickles.com/posts/parsing-csv-with-ruby/
 
CSV::HeaderConverters[:transliterate] = lambda do |header|
  header && I18n.transliterate(header)
end
 
CSV::Converters[:blank_to_nil] = lambda do |field|
  field && field.empty? ? nil : field
end

module CsvConverters
    class Importer

        def get_options
            {
                headers: true,
                header_converters: [:transliterate, :symbol],
                converters: [:all, :blank_to_nil]
            }
        end

        def transliterate(str)
            ActiveSupport::Inflector.transliterate(str)
        end
    
        def initialize(path_to_file)
            @path_to_file = path_to_file
        end

        def each_row(options={}, &block)
            CSV.foreach(@path_to_file, get_options.merge(options)) do |row|
                block.call(row)
            end
        end

        def import!
            each_row{ |row|
             puts row.inspect
            }
            xxxx
        end
    end
end