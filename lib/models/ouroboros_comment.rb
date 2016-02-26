module Models
  class OuroborosComment < Base
    def attributes
      {
        id: data["id"],
        focus: data["focus"],
        board: data["board"],
        body: data["body"],
        tags: data["tags"] || [],
        user_zooniverse_id: data["user_zooniverse_id"],
        zooniverse_id: data["zooniverse_id"]
      }
    end
  end
end
