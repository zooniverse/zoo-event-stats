module Stats
  class Processor
    attr_reader :output

    def initialize(output)
      @output  = output
    end

    def process(events)
      return if events.empty?

      known_events = events.select do |event|
        type = event_type(event)
        known_event?(event_model(type))
      end
      output.write(known_events)
    end

    private

    def known_events
      @known_events ||= %w(classification workflow_counters)
    end

    def known_event?(event_model)
      known_events.include?(event_model)
    end

    def event_model(type)
      type.split(".").last if type
    end

    def event_type(event)
      event.fetch("event_type", nil)
    end
  end
end
