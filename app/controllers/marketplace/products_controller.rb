module Marketplace
  class ProductsController < ApplicationController
    before_action :set_product, only: %i[show import]

    def index
      @products = Product.published.includes(:user, product_items: :sheet).order(created_at: :desc)
    end

    def show
    end

    def import
      ImportProductJob.perform_later(@product, Current.user)
      redirect_to marketplace_product_path(@product), notice: I18n.t("notice.product.import")
    end

    private

      def set_product
        @product = Product.published.find(params[:id])
      end
  end
end
