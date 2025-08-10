class AccountController < ApplicationController
  def index
    @user = Current.user
  end
end
