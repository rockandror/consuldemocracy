class CreateMemberTypes < ActiveRecord::Migration
  def change
    create_table :member_types do |t|
      t.string :value
      t.boolean :fixed

      t.timestamps null: false
    end

    MemberType.create :value => "Cualquier ciudadano", :fixed => true
    MemberType.create :value => "Asociaciones del Registro de Entidades Jurídicas", :fixed => true
    MemberType.create :value => "Fundaciones del Registro de Entidades Jurídicas", :fixed => true
  end
end
