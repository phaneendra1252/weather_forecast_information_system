class SessionsController < Devise::SessionsController

  skip_load_and_authorize_resource

end
