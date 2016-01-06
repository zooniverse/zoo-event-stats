module Stats
  class Processor
    attr_reader :outputs

    def initialize(outputs)
      @outputs  = outputs
    end

    def process(events)
      return if events.empty?

      known_events = events.select do |event|
        type = event_type(event)
        known_event?(event_model(type))
      end

      known_events = known_events.map do |event|
        strip_private_fields(geolocate(event))
      end

      outputs.each { |output| output.write(known_events) }
    end

    private

    def known_events
      @known_events ||= %w(classification workflow_counters talk.comment)
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

    def geolocate(event)
      return event unless event["_ip_address"]

      result = Geocoder.search(event["_ip_address"])

      if match = result[0]
        event.merge(geo: {
          country_name: match.country,
          country_code: match.country_code,
          city_name: match.city,
          coordinates: [match.longitude, match.latitude],
          latitude: match.latitude,
          longitude: match.longitude
        })
      else
        event
      end
    rescue StandardError
      event
    end

    def strip_private_fields(event)
      event.reject { |key| key =~ /\A_/ }
    end
  end
end
