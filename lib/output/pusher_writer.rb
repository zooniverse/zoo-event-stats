require 'pusher'

module Stats
  module Output
    class PusherWriter
      attr_reader :api

      def initialize(api=Pusher)
        @api = api
      end

      def write(models)
        models.each do |model|
          api.trigger(model.source, model.type, model.attributes)
        end
      rescue Pusher::Error => e
        puts "Error writing to pusher - #{e.class} - #{e.message}"
      end
    end
  end
end
