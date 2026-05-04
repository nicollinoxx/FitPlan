# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"

pin "@hotwired/strada", to: "strada.js", preload: true
pin "trix"
pin "@rails/actiontext", to: "actiontext.esm.js"

pin "bootstrap", to: "bootstrap.bundle.min.js"

pin "chartkick", to: "chartkick.js"
pin "Chart.bundle", to: "Chart.bundle.js"

pin "@rails/actioncable", to: "actioncable.esm.js"

pin_all_from "app/javascript/controllers", under: "controllers"
pin_all_from "app/javascript/channels", under: "channels"
