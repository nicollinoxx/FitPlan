class Identity::ProfilesController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    @user.update!(user_params)
    recede_or_redirect_to account_path, notice: I18n.t('notice.profiles.update')
  end

  private

    def set_user
      @user = Current.user
    end

    def user_params
      params.expect(user: [:name])
    end
end
