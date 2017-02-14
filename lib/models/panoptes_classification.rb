require_relative '../../lib/geo'

module Models
  class PanoptesClassification < Base
    def id
      data["id"]
    end

    def timestamp
      DateTime.parse(data["updated_at"])
    end

    def attributes
      {
        classification_id: data["id"],
        project_id: links["project"],
        workflow_id: links["workflow"],
        user_id: links["user"],
        subject_ids: subject_ids,
        subject_urls: subject_urls,
        geo: Geo.locate(data["user_ip"])
      }
    end

    def subject_ids
      links["subjects"]
    end

    def subject_urls
      linked \
        .fetch("subjects", [])
        .select { |subject| (subject_ids & [subject["id"]]).size > 0 }
        .flat_map { |subject| subject["locations"] }
    end
  end
end
