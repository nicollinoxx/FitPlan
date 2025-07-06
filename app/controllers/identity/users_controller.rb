class Identity::UsersController < ApplicationController
  before_action :set_user

  def edit
  end

  def update
    if @user.update(user_params)
      refresh_or_redirect_to account_path, notice: "username updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def set_user
      @user = Current.user
    end

    def user_params
      params.expect(user: [:username, :handle])
    end
end
