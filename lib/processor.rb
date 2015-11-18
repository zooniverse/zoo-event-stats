module Stats
  class Processor
    attr_reader :output

    def initialize(output)
      @output  = output
    end

    def process(event)
      type = event_type(event)
      if known_event?(event_model(type))
        output.write(event)
      else
        puts "not sure what event type this is..#{type}"
      end
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
