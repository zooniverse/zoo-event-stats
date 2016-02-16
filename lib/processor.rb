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
      outputs.each { |output| output.write(models) }
    end
  end
end
