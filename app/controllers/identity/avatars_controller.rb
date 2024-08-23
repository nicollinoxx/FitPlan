class Identity::AvatarsController < ApplicationController
  before_action :set_user

  def show
  end

  def edit
  end

  def update
    if @user.update(user_params)
      refresh_or_redirect_to home_path, notice: 'Avatar updated successfully'
    else
      respond_to do |format|
        format.turbo_stream {
          render turbo_stream: turbo_stream.replace('avatar',
                      partial: 'identity/avatars/form',
                       locals: { user: @user }) }
      end
    end
  end

  def destroy
    @user.avatar.purge_later

    recede_or_redirect_to home_path, notice: 'Avatar destroyed successfully'
  end

  private
    def set_user
      @user = Current.user
    end

    def user_params
      params.permit(:avatar)
    end
end
