require 'pusher'

module Stats
  module Output
    class PusherWriter
      attr_reader :api

      def initialize(api=Pusher)
        @api = api
      end

      def write(events)
        events.map do |event|
          source, type = event.fetch("event_type").split(".")
          api.trigger(source, type, event)
        end
      end
    end
  end
end
