Apipie.configure do |config|
  config.app_name                = "SampleApp"
  config.api_base_url            = ""
  config.doc_base_url            = "/apipie"
  config.translate               = false
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/**/*.rb"
end
