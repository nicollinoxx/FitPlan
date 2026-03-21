class ImportProductJob < ApplicationJob
  queue_as :default

  def perform(product, user)
    product.import_to user
  end
end
