class SessionsController < ApplicationController
  skip_before_action :authenticate, only: %i[ new create omniauth ]
  before_action :set_session, only: :destroy

  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to sign_in_path, notice: I18n.t('alert.rate_limit') }

  def index
    @sessions = Current.user.sessions.order(created_at: :desc)
  end

  def new
    hold_handoff if turbo_native_app?
  end

  def create
    if user = User.authenticate_by(email: params[:email], password: params[:password])
      start_new_session_for(user)
    else
      redirect_to sign_in_path(email_hint: params[:email]), notice: I18n.t('alert.session.invalid')
    end
  end

  def omniauth
    if user = User.from_omniauth(request.env['omniauth.auth'])
      if handoff = session.delete(:session_handoff)
        SessionHandoff.complete(handoff, user)
        render :handed_off
      else
        start_new_session_for(user)
      end
    else
      redirect_to sign_in_path, notice: I18n.t('alert.session.omniauth')
    end
  end

  def destroy
    @session.destroy; redirect_to(sessions_path, notice: I18n.t('notice.session.destroy'))
  end

  private

    def set_session
      @session = Current.user.sessions.find(params[:id])
    end

    def hold_handoff
      @handoff = cookies.signed[:session_handoff] || SessionHandoff.issue
      cookies.signed[:session_handoff] = { value: @handoff, httponly: true, expires: SessionHandoff::EXPIRES_IN }
    end
end
