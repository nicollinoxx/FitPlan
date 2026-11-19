# Be sure to restart your server when you modify this file.

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
