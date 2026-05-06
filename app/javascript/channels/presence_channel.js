import consumer from "channels/consumer"

consumer.subscriptions.create("PresenceChannel", {
  connected() {
    this.heartbeatInterval = setInterval(() => this.perform("heartbeat"), 5 * 60 * 1000)
  },

  disconnected() {
    clearInterval(this.heartbeatInterval)
  }
})
