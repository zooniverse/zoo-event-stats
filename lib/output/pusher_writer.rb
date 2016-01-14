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
          begin
            api.trigger(source, type, event)
          rescue Pusher::Error => e
            puts "Error writing to pusher - #{e.class}"
          end
        end
      end
    end
  end
end
