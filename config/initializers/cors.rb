# Configurations for CORS middleware added september 2020
# https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    #resource '*', headers: :any, methods: [:post]

    resource '/messages',
      :headers => :any,
      :methods => [:post],
      :max_age => 0
  end
end