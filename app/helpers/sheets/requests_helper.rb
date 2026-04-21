module Sheets::RequestsHelper
  def sheet_request_user(request, filter)
    filter == "sent" ? request.recipient : request.sender
  end

  def sheet_request_avatar(request, filter)
    user = sheet_request_user(request, filter)

    if user.avatar.attached?
      image_tag user.avatar, class: "rounded-circle object-fit-cover me-2", style: "width: 40px; height: 40px;", alt: ""
    else
      content_tag(:div, class: "me-2 rounded-circle bg-secondary d-flex align-items-center justify-content-center text-white", style: "width: 40px; height: 40px;") do
        content_tag(:i, "", class: "bi bi-person-fill fs-5")
      end
    end
  end

  def sheet_request_direction_label(filter)
    filter == "sent" ? t("sheet_request_received") : t("sheet_request_shared")
  end
end
