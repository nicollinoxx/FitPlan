module Sheets
  class ImportsController < ApplicationController
    before_action :set_user

    def index
      @sheet_imports = @user.sheet_imports.includes(:product, :sheets).recent_first
    end

    def show
      @sheet_import = @user.sheet_imports.includes(:product, :sheets).find(params[:id])
    end

    private

      def set_user
        @user = Current.user
      end
  end
end
