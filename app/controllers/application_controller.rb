class ApplicationController < ActionController::Base
  before_action :set_current_request_details
  before_action :claim_session_handoff, if: :session_handoff_pending?
  before_action :authenticate, except: %i[ change_locale ]
  before_action :resume_session, only: %i[ change_locale ]

  include Locable

  helper_method :current_user_avatar, :session_handoff_pending?

  private
    def authenticate
      redirect_to welcome_path unless resume_session
    end

    def resume_session
      Current.session = Session.find_by_id(cookies.signed[:session_token])
    end

    def start_new_session_for(user)
      @session = user.sessions.create!

      cookies.signed.permanent[:session_token] = { value: @session.id, httponly: true }
      redirect_to sheets_path(format: :html)
    end

    # Whichever page the app shows when it comes back from signing in through a
    # provider trades the pending code for a session (see SessionHandoff).
    def session_handoff_pending?
      turbo_native_app? && cookies.signed[:session_handoff].present?
    end

    def claim_session_handoff
      if user = SessionHandoff.claim(cookies.signed[:session_handoff])
        cookies.delete(:session_handoff)
        start_new_session_for(user)
      end
    end

    def set_current_request_details
      Current.user_agent = request.user_agent
      Current.ip_address = request.ip
    end

    def current_user_avatar
      @current_user_avatar ||= Current.user&.avatar
    end
end
