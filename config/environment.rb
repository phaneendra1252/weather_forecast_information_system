# Load the Rails application.
require File.expand_path('../application', __FILE__)

# for using constants
if "#{Rails.env}" == "development"
  app_env_vars = File.join(Rails.root, 'config', 'initializers', 'app_env_vars.rb')
  load(app_env_vars) if File.exists?(app_env_vars)
end

# Initialize the Rails application.
Rails.application.initialize!
