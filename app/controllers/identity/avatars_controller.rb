class Identity::AvatarsController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    @user.update!(user_params)
    recede_or_redirect_to account_path, notice: I18n.t('notice.avatar.update')
  end

  def destroy
    @user.avatar.purge_later
    refresh_or_redirect_to account_path, notice: I18n.t('notice.avatar.destroy')
  end

  private
    def set_user
      @user = Current.user
    end

    def user_params
      params.expect(user: [:avatar])
    end
end
