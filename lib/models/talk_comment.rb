module Models
  class TalkComment < Base
    def attributes
      {
        project_id: data["project_id"],
        board_id: data["board_id"],
        discussion_id: data["discussion_id"],
        focus_id: data["focus_id"],
        focus_type: data["focus_type"],
        section: data["section"],
        geo: Geo.locate(data["_ip_address"])
      }
    end
  end
end
