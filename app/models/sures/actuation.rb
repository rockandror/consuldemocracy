class Sures::Actuation < ApplicationRecord
    belongs_to :geozone

    scope :study, -> { where(status: "study") }
    scope :tramit, -> { where(status: "tramit") }
    scope :process, -> { where(status: "process") }
    scope :fhinish, -> { where(status: "fhinish") }

    self.table_name = "sures_actuations"

    translates :proposal_title,         touch: true
    translates :proposal_objective,     touch: true
    translates :territorial_scope,      touch: true
    translates :location_performance,   touch: true
    translates :technical_visibility,   touch: true
    translates :actions_taken,          touch: true
    include Globalizable


    validates :proposal_title, presence: true
    validates :status, presence: true
    validates :borought, presence: true
    validate :valid_annos


    private

    def valid_annos
        if self.check_anno 
            if !self.annos.match(/^\d{4}$/)
                self.errors.add(:annos, "Se han introducido más de 4 dígitos o formato incorrecto")
            end
        elsif self.check_multianno
            if !self.annos.match(/^(\d{4};)*\d{4}$/)
                self.errors.add(:annos, "Se han introducido un formato incorrecto debe introducirse 'XXXX;XXXX' o 'XXXX'")
            end
        end
    end
end

