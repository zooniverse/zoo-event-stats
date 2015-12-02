require 'yaml'

module Stats
  class Config
    def self.load_yaml(filename, environment)
      path = File.expand_path(File.join('..', '..', 'config', filename), __FILE__)
      YAML.load_file(path).fetch(environment.to_s)
    end

    def self.rack_environment
      ENV["RACK_ENV"] || :development
    end

    def self.stats_environment
      ENV["ZOO_STATS_ENV"] || :development
    end
  end
end
