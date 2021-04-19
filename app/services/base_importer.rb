require 'csv_converters'


  class BaseImporter

    OPTIONS = {
      headers: true,
      encoding:'iso-8859-1:utf-8',
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
    rescue => e
      puts "========= ERROR #{e}"
      block.call(nil)
    end

    def import!
      each_row{ |row| puts row.inspect }
    end

    def transliterate(str)
      ActiveSupport::Inflector.transliterate(str)
    end    
  end
