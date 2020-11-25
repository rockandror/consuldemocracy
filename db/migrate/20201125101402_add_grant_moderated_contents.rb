class AddGrantModeratedContents < ActiveRecord::Migration[5.0]
  def change
    if !Rails.env.development? && !Rails.env.text?
    execute "ALTER TABLE moderated_contents
      OWNER TO participacion_owner;
    GRANT ALL ON TABLE moderated_contents TO participacion_owner;
    GRANT SELECT ON TABLE moderated_contents TO participacion_read;"
    end
  end
end
