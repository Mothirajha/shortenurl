# Require config/environment.rb
require ::File.expand_path('../config/environment', __File__)

run Sinatra::Application
