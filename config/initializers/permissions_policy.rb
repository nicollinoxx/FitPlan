# Be sure to restart your server when you modify this file.

# Rails' `config.permissions_policy` still emits the legacy `Feature-Policy`
# header, which browsers no longer read. Send the standard `Permissions-Policy`
# header instead. See https://developer.mozilla.org/docs/Web/HTTP/Headers/Permissions-Policy
Rails.application.config.action_dispatch.default_headers["Permissions-Policy"] = [
  "camera=()",
  "microphone=()",
  "geolocation=()",
  "gyroscope=()",
  "accelerometer=()",
  "magnetometer=()",
  "usb=()",
  "payment=()",
  "fullscreen=(self)"
].join(", ")
