module Models
  class TalkComment < Base
    def attributes
      {
        project_id: data["project_id"],
        board_id: data["board_id"],
        discussion_id: data["discussion_id"],
        focus_id: data["focus_id"],
        focus_type: data["focus_type"],
        user_id: data["user_id"],
        section: data["section"],
        body: data["body"],
        created_at: data["created_at"],
        geo: Geo.locate(data["user_ip"])
      }
    end
  end
end
