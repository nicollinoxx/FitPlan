class Identity::SettingsController < ApplicationController
  before_action :set_user

  def show
  end

  private

    def set_user
      @user = Current.user
    end
end
