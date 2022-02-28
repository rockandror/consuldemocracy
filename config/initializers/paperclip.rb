Paperclip.options[:content_type_mappings] = {
  pdf: "application/pdf"
}
Paperclip.options[:command_path] = '/usr/bin'

Paperclip.interpolates :relative_url_root  do |attachment, style|
  Rails.application.config.relative_url_root.to_s
end
