class InsertPeriodDoubleVerificationInSettings < ActiveRecord::Migration[5.0]
  def change
    Setting.create(:key => "months_to_double_verification", :value => 3)
  end
end
