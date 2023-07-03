require_dependency Rails.root.join("app", "models", "user").to_s

class User
  devise :lockable

  GENDER = %w[male female undefined].freeze
  LOCATION = %w[
    adeje
    arafo
    arico
    arona
    buenavista-del-norte
    candelaria
    el-rosario
    el-sauzal
    el-tanque
    fasnia
    garachico
    granadilla-de-abona
    guia-de-isora
    guimar
    icod-de-los-vinos
    la-guancha
    la-laguna
    la-matanza-de-acentejo
    la-orotava
    la-victoria-de-acentejo
    los-realejos
    los-silos
    puerto-de-la-cruz
    san-juan-de-la-rambla
    san-miguel-de-abona
    santa-cruz-de-tenerife
    santa-ursula
    santiago-del-teide
    tacoronte
    tegueste
    vilaflor
    ].freeze


  validates :gender, presence: true, on: :create
  validates :gender, inclusion: { in: GENDER }, unless: -> { gender.blank? }, on: :create
  validates :date_of_birth, presence: true, on: :create
  validates :location, presence: true, on: :create
  validates :location, inclusion: { in: LOCATION }, unless: -> { location.blank? }, on: :create

  scope :male,           -> { where(gender: "male") }
  scope :female,         -> { where(gender: "female") }

  audited except: [
    :sign_in_count,
    :last_sign_in_at,
    :current_sign_in_at,
    :locked_at,
    :unlock_token,
    :failed_attempts
  ]

  def self.maximum_attempts
    (Setting["login_attempts_before_lock"] || 2).to_i
  end

  def self.unlock_in
    (Setting["time_to_unlock"] || 2).to_i.minutes
  end
end
