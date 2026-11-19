# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  object_storage = "https://*.your-objectstorage.com"

  config.content_security_policy do |policy|
    policy.default_src     :self
    policy.base_uri        :self
    policy.object_src      :none
    policy.frame_ancestors :self
    policy.script_src      :self
    policy.style_src       :self, :unsafe_inline
    policy.font_src        :self, :data
    policy.img_src         :self, :data, :blob, object_storage
    policy.media_src       :self, :blob, object_storage
    policy.connect_src     :self
  end

  # Nonce the importmap and any other inline scripts. Styles are left out on
  # purpose: views rely on inline style attributes, and a style-src nonce would
  # make browsers ignore 'unsafe-inline'.
  config.content_security_policy_nonce_generator = ->(_request) { SecureRandom.base64(16) }
  config.content_security_policy_nonce_directives = %w[script-src]
end
