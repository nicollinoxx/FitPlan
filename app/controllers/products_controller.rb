class ProductsController < ApplicationController
  before_action :set_user
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @products = @user.products.includes(product_items: :sheet).order(created_at: :desc)
  end

  def show
  end

  def new
    @product = @user.products.build(status: "draft")
  end

  def create
    @product = @user.products.build(product_params)

    if @product.save
      redirect_to product_url(@product), notice: I18n.t("notice.product.create")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @product.update(product_params)
      redirect_to product_url(@product), notice: I18n.t("notice.product.update")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @product.destroy!
    redirect_to products_url, notice: I18n.t("notice.product.destroy")
  end

  private

    def set_product
      @product = @user.products.find(params[:id])
    end

    def product_params
      params.expect(product: [ :title, :description, :status, sheet_ids: [] ]).compact_blank
    end

    def set_user
      @user = Current.user
    end
end
