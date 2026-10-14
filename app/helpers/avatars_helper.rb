module AvatarsHelper
  def avatar_image_tag(avatar, size:, **options)
    source = avatar.variable? ? avatar.variant(resize_to_fill: [ size * 2, size * 2 ]) : avatar

    image_tag source, width: size, height: size, **options
  end
end
