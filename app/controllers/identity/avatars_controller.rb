class Identity::AvatarsController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      refresh_or_redirect_to account_path, notice: I18n.t('notice.avatar.update')
    else
      render turbo_stream: turbo_stream.replace('form', partial: 'identity/avatars/form', locals: { user: @user })
    end
  end

  def destroy
    @user.avatar.purge_later

    recede_or_redirect_to account_path, notice: I18n.t('notice.avatar.destroy')
  end

  private
    def set_user
      @user = Current.user
    end

    def user_params
      params.require(:user).permit(:avatar)
    end
end
