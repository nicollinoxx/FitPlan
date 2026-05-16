class SheetShareMailer < ApplicationMailer
  def new_sheet_share
    @share     = params[:share]
    @sender    = @share.sender
    @recipient = @share.recipient

    mail(to: @recipient.email, subject: t(".subject", name: @sender.name))
  end
end
