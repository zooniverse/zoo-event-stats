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
        subject_ids: links["subjects"],
        geo: Geo.locate(data["user_ip"])
      }
    end
  end
end
