module Models
  class PanoptesWorkflowCounter < Base
    def attributes
      {
        project_id: data["project_id"],
        workflow_id: data["workflow_id"],
        subjects_count: data["subjects_count"],
        retired_subjects_count: data["retired_subjects_count"],
        classifications_count: data["classifications_count"]
      }
    end
  end
end
