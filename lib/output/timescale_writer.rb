require 'pg'

module Stats
  module Output
    class TimescaleWriter
      attr_reader :pg_conn

      def initialize
        # https://www.rubydoc.info/gems/pg/PG/Connection#initialize-instance_method
        @pg_conn = PG.connect(ENV[PG_CONNECTION_STRING])
      end

      def write(models)
        # TODO: Add guard here to only ingest data that meets the schema
        # avoid ouroboros data and panoptes talk data until we have verified
        # the schema conformance here
        # return unless model.type && model.source == panoptes classificaiton

        values_list = models.map do |model|
          "(#{sql_values(model).join(",")})"
        end

        # TODO: look at making this a prepared insert statement
        multi_row_insert_sql = <<~SQL
        INSERT INTO events #{event_columns}
        VALUES
          #{values_list.join(",")}
        ON CONFLICT ON CONSTRAINT events_pkey
        DO NOTHING;
        SQL

        # TODO: look at making this faster using COPY statement
        # https://infinum.co/the-capsized-eight/superfast-csv-imports-using-postgresqls-copy
        pg_conn.exec(multi_row_insert_sql)
      end

      def sql_values(model)
        # each model should become a row of insert sql
        # e.g. (1, 'Cheese', 9.99)
        # see PanoptesClassification for the data details
        attributes = model.attributes

        [
          model.id,
          model.type,
          model.source,
          model.time,
          attributes.project_id,
          attributes.workflow_id,
          attributes.user_id,
          remaining_data(model),
          session_time(model)
        ]
      end

      private

      def event_columns
        @event_columns ||= %w(event_id event_type event_source event_time project_id workflow_id user_id data session_time).join(',')
      end

      def remaining_data(model)
        # TODO: do we want to store the metadata or the diff of the data minus what we have?
        # attributes.data - attributes already in payload
      end

      def session_time(model)
        metadata = model.dig('data','metadata')
        started_at = started_at['started_at']
        finished_at = started_at['finished_at']

        # TODO: convert these to time objects
        # taking into account the TZ info in the string
        # and subtracting them to find the diff

      end
    end
  end
end
