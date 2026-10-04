class ApplicationController < ActionController::Base
  before_action :set_current_request_details
  before_action :authenticate, except: %i[ change_locale ]
  before_action :resume_session, only: %i[ change_locale ]

  include Locable

  helper_method :current_user_avatar

  private
    def authenticate
      redirect_to welcome_path unless resume_session
    end

    def resume_session
      Current.session = Session.find_by_id(cookies.signed[:session_token])
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end

    def current_user_avatar
      @current_user_avatar ||= Current.user&.avatar
    end
end
