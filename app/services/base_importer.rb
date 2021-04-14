require 'csv_converters'


  class BaseImporter

    OPTIONS = {
      headers: true,
      header_converters: [:transliterate, :symbol],
      converters: [:all, :blank_to_nil],
      col_sep: ?;
    }

    def initialize(path_to_file = '')
      @path_to_file = path_to_file
    end

    def each_row(options = {}, &block)
      CSV.foreach(@path_to_file, OPTIONS.merge(options)) do |row|
        block.call(row)
      end
    end

    # def each_row(options = {})
    #   ##yyy
    #   text = File.read(@path_to_file)
    #   puts "============================"
    #   puts CSV.parse(text, headers: false)
    #   puts "==============================="
    #   xxxxxxxxx
    #   CSV.foreach(@path_to_file, OPTIONS.merge(options)) do |row|
    #     puts "==============================="
    #     puts row
    #     puts "==============================="
    #     xxxxx
    #   end
    # end

    def import!
      each_row{ |row| puts row.inspect }
    end

    def transliterate(str)
      ActiveSupport::Inflector.transliterate(str)
    end    
  end
