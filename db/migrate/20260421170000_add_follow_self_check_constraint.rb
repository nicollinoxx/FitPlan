class AddFollowSelfCheckConstraint < ActiveRecord::Migration[8.1]
  def change
    add_check_constraint :follows, 'follower_id <> followed_id', name: 'follows_follower_not_equal_followed'
  end
end