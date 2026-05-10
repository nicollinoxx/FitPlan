module Scrollable
  extend ActiveSupport::Concern

  private

  def scrollable_to collection
    set_page_and_extract_portion_from collection
    sleep 2.seconds unless @page.first?
  end
end
