require_relative '../es/client'

module Stats
  module Output
    class TimescaleWriter
      attr_reader :config, :client

      def initialize
        @search_client = Stats::Es::Client.new(:stats)
        @config = @search_client.config
        @client = @search_client.es_client
      end

      def health
        client.cluster.health
      end

      def get(id)
        client.get doc_defaults.merge(id: id)
      end

      def write(models)
        operations = models.map { |model| operation_for_model(model) }
        client.bulk body: operations
      end

      def operation_for_model(model)
        formatter = ModelFormatter.new(model)
        doc = doc_defaults.merge(
          data: model.attributes.merge(formatted_data(formatter)),
          _id: formatter.id,
          op_type: "create"
        )
        {index: doc}
      end

      def doc_defaults
        { _index: config[:index], _type: "event" }
      end

      def formatted_data(formatter)
        {
          "event_type" => formatter.type,
          "event_source" => formatter.source,
          "event_time" => formatter.time
        }
      end

      private

      class ModelFormatter
        attr_reader :event

        def initialize(event)
          @event = event
        end

        def id
          event.id
        end

        def source
          event.source || "unknown"
        end

        def type
          event.type
        end

        def time
          event.timestamp && event.timestamp.to_s
        end

        private

        def event_type_details
          event["event_type"].split(".")
        end
      end
    end
  end
end
