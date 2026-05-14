module Sheets::SharesHelper
  def share_other_user(share)
    share.sender == Current.user ? share.recipient : share.sender
  end
end
