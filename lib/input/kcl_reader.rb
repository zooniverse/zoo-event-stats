require 'aws/kclrb'
require 'base64'

module Stats
  module Input
    class KclReader < Aws::KCLrb::RecordProcessorBase
      attr_reader :processor

      def initialize(processor=$stderr)
        @processor = processor
      end

      def init_processor(shard_id)
      end

      def process_records(records, checkpointer)
        return if records.empty?

        events = records.map do |record|
          data = Base64.decode64(record['data'])
          hash = JSON.load(data)
        end

        processor.process(events)
        checkpoint_helper(checkpointer, records.last["sequenceNumber"])
      end

      def shutdown(checkpointer, reason)
        checkpoint_helper(checkpointer)  if 'TERMINATE' == reason
      end

      private

      # Helper method that retries checkpointing once.
      # @param checkpointer [Aws::KCLrb::Checkpointer] The checkpointer instance to use.
      # @param sequence_number (see Aws::KCLrb::Checkpointer#checkpoint)
      def checkpoint_helper(checkpointer, sequence_number=nil)
        begin
          checkpointer.checkpoint(sequence_number)
        rescue Aws::KCLrb::CheckpointError => e
          # Here, we simply retry once.
          # More sophisticated retry logic is recommended.
          checkpointer.checkpoint(sequence_number) if sequence_number
        end
      end
    end
  end
end
