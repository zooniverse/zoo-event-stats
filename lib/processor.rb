require_relative 'geo'
require_relative 'models'

module Stats
  class Processor
    attr_reader :outputs

    def initialize(outputs)
      @outputs  = outputs
    end

    def process(events)
      models = events.map { |event| Models.for(event) }.compact
      outputs.each do |output|
        # TODO: handle error for each writer
        #
        # apparently if we get an uncaught error here
        # it will drop the current batch
        # not great for counting things properly
        # and we do get connectivity issues with ES and we will with PG
        #
        # https://docs.aws.amazon.com/streams/latest/dev/troubleshooting-consumers.html#w2aac13c19b5
        output.write(models)
      end
    end
  end
end
