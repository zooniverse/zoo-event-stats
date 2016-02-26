module Models
  class OuroborosClassification < Base
    def timestamp
      DateTime.parse(data["timestamp"])
    end

    def attributes
      {
        user_id:    format_user_id(data),
        user_ip:    nil, # Incompatible with events.zooniverse.org, but not giving out IP addresses anymore
        subjects:   format_subjects(data),
        lang:       format_language(data),
        user_agent: format_user_agent(data),
        user_name:  format_user_name(data),
        data:       nil, # Incompatible with events.zooniverse.org, but not giving out raw classification data of all projects
        created_at: timestamp,
        project:    data["project"],
        geo:        Geo.locate(data["user_ip"])
      }
    end

    private

    def format_user_id(data)
      data.fetch("user_id", "Not Logged In")
    end

    def format_subjects(data)
      data["subject"].map {|subject| subject["zooniverse_id"] }.join(",")
    end

    def format_language(data)
      lang = find_annotation_with_key(data["annotations"], "language")
      
      if lang == "$DEFAULT"
        "en-US"
      elsif [5,2].include?(lang.size)
        lang
      else
        "Unknown"
      end
    end

    def format_user_agent(data)
      find_annotation_with_key(data["annotations"], "agent") || find_annotation_with_key(data["annotations"], "user_agent")
    end

    def format_user_name(data)
      data.fetch("user", "Not Logged In")
    end

    def find_annotation_with_key(annotations, key)
      return unless annotations
      annotation = annotations.find { |annotation| annotation.key?(key) }
      annotation[key] if annotation
    end
  end
end
