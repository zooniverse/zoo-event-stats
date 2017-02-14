module Models
  class Base
    def initialize(event)
      @event = event
    end

    attr_reader :event

    def id
      Digest::SHA1.hexdigest("#{attributes}")
    end

    def source
      event.fetch("source")
    end

    def type
      event.fetch("type")
    end

    def timestamp
      if event["timestamp"]
        DateTime.parse(event["timestamp"])
      end
    end

    def attributes
      {}
    end

    private

    def data
      event["data"]
    end

    def links
      data["links"]
    end

    def linked
      event["linked"]
    end
  end
end
