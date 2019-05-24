module Admin::Census::Local::ImportationsHelper
  def errors_for(importation, field)
    if importation.errors.include? field
      content_tag :div, class: "error" do
        importation.errors[field].join(", ")
      end
    end
  end
end
