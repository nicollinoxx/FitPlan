module Sheets::SharesHelper
  def share_other_user(share)
    share.sender == Current.user ? share.recipient : share.sender
  end

  def share_pending_count(share)
    share.sheet_requests.count(&:pending?)
  end
end
