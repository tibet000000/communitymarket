class CommunityMarket::API < Grape::API
  prefix 'api'
  version 'v1', using: :path
  format :json          # input must be json
  default_format :json  # assume json if no Content-Type is supplied
  default_error_formatter :json
  formatter :json, Grape::Formatter::Rabl

  helpers do

    def declared_params
      declared(params, include_missing: false)
    end

    def app_version_compatible? app_version
      true
    end

    def current_user
      @current_user ||= if params[:auth_token]
        @user = User.find_by_auth_token params[:auth_token]
        fail! 402, "Invalid auth token" unless @user
        @user
      end
    end

    def validate_user!
      fail! 403, "Login required" unless current_user
    end

    def fail! code, message
      error!({error_message:message, error_code:code}, 200)
    end


  end

  rescue_from Grape::Exceptions::ValidationErrors do |e|
    Rack::Response.new({error_code: 400, error_message: e.message}.to_json, 200, "Content-Type" => "application/json").finish
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    Rack::Response.new({error_code: 401, error_message: e.message}.to_json, 200, "Content-Type" => "application/json").finish
  end

  rescue_from :all do |e|
    Rack::Response.new({error_code: 500, error_message: e.message}.to_json, 200, "Content-Type" => "application/json").finish
  end

  mount Auth
  mount Posts
  mount Categories
  mount Groups
  mount Tags


  add_swagger_documentation api_version:'v1', mount_path: "/docs", hide_documentation_path:true
end
