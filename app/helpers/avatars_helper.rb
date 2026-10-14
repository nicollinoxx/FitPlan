module AvatarsHelper
  # Avatars come straight off a phone camera and are accepted up to 4MB, while
  # every place that shows one draws it as a circle of 90 pixels or less. A
  # variant at twice the drawn size is what a dense screen needs and nothing
  # beyond it, and it is generated once and then served from storage.
  #
  # The variant scales but does not crop, and it loads every frame rather than
  # the first: cropping an animated GIF leaves a still image, because vips lays
  # its frames out as one tall strip and a crop keeps a single one. Every place
  # that shows an avatar draws it with object-fit: cover, so the circle is cut
  # by the stylesheet and the file does not have to arrive square.
  #
  # Nothing restricts the upload to an image, so a blob that cannot be resized
  # is served as it is rather than raising on the way to the page.
  def avatar_image_tag(avatar, size:, **options)
    source = avatar.variable? ? avatar.variant(loader: { n: -1 }, resize_to_limit: [ size * 2, size * 2 ]) : avatar

    image_tag source, width: size, height: size, **options
  end
end
