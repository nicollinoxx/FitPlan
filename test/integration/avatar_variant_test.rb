require "test_helper"

class AvatarVariantTest < ActionDispatch::IntegrationTest
  setup { @user = users(:lazaro_nixon) }

  def attach(file, type)
    @user.avatar.attach(io: File.open(Rails.root.join("test/fixtures/files", file)),
                        filename: file, content_type: type)
  end

  # A GIF's frames are laid out as one tall strip, so a variant that crops keeps
  # a single frame and the avatar stops moving.
  def frames_in(processed)
    File.binread(ActiveStorage::Blob.service.path_for(processed.key)).scan("\x21\xF9\x04".b).size
  end

  test "an animated avatar keeps moving through the variant" do
    attach "animated_avatar.gif", "image/gif"
    original = File.binread(Rails.root.join("test/fixtures/files/animated_avatar.gif")).scan("\x21\xF9\x04".b).size
    assert_operator original, :>, 1, "a fixture precisa ser animada"

    processed = @user.avatar.variant(loader: { n: -1 }, resize_to_limit: [ 112, 112 ]).processed

    assert_equal original, frames_in(processed)
  end

  test "a still avatar is still resized down" do
    attach "avatar.png", "image/png"
    processed = @user.avatar.variant(loader: { n: -1 }, resize_to_limit: [ 112, 112 ]).processed

    image = Vips::Image.new_from_file ActiveStorage::Blob.service.path_for(processed.key)
    assert_operator image.width, :<=, 112
    assert_operator image.height, :<=, 112
  end

  test "profiles serve a representation rather than the blob" do
    attach "avatar.png", "image/png"
    sign_in_as @user
    get social_profiles_url(query: @user.name)

    assert_response :success
    assert_select "img[width=?][src*=?]", "56", "representations"
    assert_no_match %r{/rails/active_storage/blobs/redirect}, response.body
  end
end
