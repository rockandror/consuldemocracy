require "csv"
require 'base_importer'

class ImportUser < BaseImporter
  include ActiveModel::Model

  ATTRIBUTES = %w[usuario email nombre primer_apellido segundo_apellido telefono tipo_documento documento sexo fecha_nacimiento tipo_via nombre_via numero_via planta puerta portal distrito barrio codigo_postal].freeze

  ALLOWED_FILE_EXTENSIONS = %w[.csv].freeze

  attr_accessor :file

  validates :file, presence: true
  validate :file_extension, if: -> { @file.present? }
  validate :valid_headers?, if: -> { @file.present? && valid_extension? }

  def initialize(attrs = {})
    super
    if attrs.present?
      attrs.each do |attr, value|
        public_send("#{attr}=", value)
      end
    end
  end

  def save
    return false if invalid?
    @path_to_file = file.path
    valid = valid_users
    if valid.blank?
      error_import = import!
    end
    puts "===================="
    puts error_import
    puts "===================="
    if valid == false 
      valid = {0 => "Fichero en blanco"}
    elsif valid.blank? && error_import.blank?
      true
    else
      valid.blank? ? error_import : valid
    end
  rescue => e
    {0 => "ERROR: El fichero no tiene formato correcto de CSV ni codificación en UTF-8"}
  end

  def save!
    validate! && save
  rescue 
    false
  end

  private

    def valid_users
      count = 0
      message = "Fila #{count}, el nombre, el email y el documento no pueden estar en blanco."
      errors = {}
      blank_file = true
      begin
        each_row do |row|
          blank_file = false
          begin
            count = count + 1
            if row.blank?
              errors.merge!({count => message})
            else
              if row[:usuario].blank?
                errors.merge!({count => "Usuario en blanco"})
              elsif !User.find_by(username: row[:usuario]).blank?
                errors.merge!({count => "El nombre de usuario ya está en uso."})
              elsif row[:email].blank?
                errors.merge!({count => "Email en blanco"})
              elsif !User.find_by(email: row[:email]).blank?
                errors.merge!({count => "El email ya está en uso."})
              elsif row[:documento].blank?
                errors.merge!({count => "Documento en blanco"})
              elsif !User.find_by(document_number: row[:documento]).blank?
                errors.merge!({count => "Ya existe un usuario con el mismo documento."})
              end
            end
          rescue
            errors.merge!({count => message})
          end
        end
        blank_file == false ? errors : false
      rescue => e
        errors.merge!({count => e})
      end     
    end

    def import!
      super
      count = 0
      errors = {}
      begin
        each_row do |row|
          begin
            user = build_user(row)
            if user.save!
              if user.adress.save!
                puts "===================================================="
                puts "Usuario creado"
                puts "===================================================="
              else
                puts "===================================================="
                puts  user.adress.errors.full_messages
                puts "===================================================="
                errors.merge!({count =>  user.adress.errors.full_messages })
              end
            else
              puts "===================================================="
              puts  user.errors.full_messages
              puts "===================================================="
              errors.merge!({count =>  user.errors.full_messages })
            end
          rescue
            puts "========================================================================="
            puts "El usuario '#{row[:usuario]}' no se ha podido generar."
            puts  user.adress.errors.full_messages
            puts  user.errors.full_messages
            puts "========================================================================="
            errors.merge!({count =>  "El usuario '#{row[:usuario]}' no se ha podido generar. -> #{user.errors.full_messages}" })
          end
        end
        errors
      rescue => e
        puts "========================================================================="
        puts "ERROR: #{e}."
        puts "========================================================================="
        errors.merge!({count => e})
      end
    end

    def valid_data(row)
      !(row[:usuario].blank? || row[:email].blank? || row[:documento].blank?)
    end

    def build_user(row)
      user = User.new(username: row[:usuario], email: row[:email], name: row[:nombre], last_name: row[:primer_apellido], 
        last_name_alt: row[:segundo_apellido], phone_number: row[:telefono], document_number: row[:documento], 
        date_of_birth: row[:fecha_nacimiento], terms_of_service: "1", residence_verified_at: Time.current, 
        verified_at: Time.current)
      user.document_type = get_document_type(row[:tipo_documento]) if !row[:tipo_documento].blank?
      user.gender = get_gender(row[:sexo]) if !row[:sexo].blank?
      pass = Digest::SHA1.hexdigest("#{user.created_at.to_s}--#{user.username}")[0,8].upcase
      user.password = "12345678" #pass
      user.password_confirmation = "12345678" #pass
      user.adress = Adress.new()
      user.adress.road_type = row[:tipo_via]
      user.adress.road_name = row[:nombre_via]
      user.adress.road_number = row[:numero_via]
      user.adress.floor = row[:planta]
      user.adress.door = row[:puerta]
      user.adress.gate = row[:portal]
      user.adress.district = get_district(row[:district]) if !row[:district].blank?
      user.adress.borought = get_borought(row[:borought]) if !row[:borought].blank?
      user.adress.postal_code = row[:codigo_postal]
      user
    end

    def empty_row?(row)
      row.all? { |_, cell| cell.nil? }
    end

    def file_extension
      return if valid_extension?
      errors.add :file, :extension, valid_extensions: ALLOWED_FILE_EXTENSIONS.join(", ")
    end

    def valid_extension?
      ALLOWED_FILE_EXTENSIONS.include?(File.extname(file.original_filename))
    end

    def valid_headers?
      headers = CSV.open(file.path, &:readline)
    end

    def get_gender(gender)
      case gender
      when "masculino"
        "male"
      when "femenino"
        "female"
      else
        nil
      end
    end

    def get_document_type(type)
      case type
      when "nif"
        1
      when "pasaporte"
        2
      when "tarjeta de residencia"
        3
      else
        nil
      end
    end

    def get_district(district)
      Geozone.find_by(name: district).id
    end

    def get_borought(borought)
      Proposal.find_by(title: borought).where(comunity_hide: :true).id
    end
end
