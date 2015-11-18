module Stats
  class Classification
    attr_reader :hash

    def initialize(hash)
      @hash = hash
    end

    def id
      hash.fetch("classification_id")
    end

    def project_id
      hash.fetch("project_id")
    end

    def user_id
      hash.fetch("user_id")
    end

    def event_id
      hash.fetch("event_id")
    end

    def event_type
      hash.fetch("event_type")
    end

    def event_time
      hash.fetch("event_time")
    end
  end
end
