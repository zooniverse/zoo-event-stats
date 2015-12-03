require 'yaml'

module Stats
  class Config

    DEV_ENV = "development"

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

    def self.rack_development?
      rack_environment == DEV_ENV
    end

    def self.stats_development?
      stats_environment == DEV_ENV
    end

    def self.service_env(service)
      case service
      when :api
        rack_environment
      when :stats
        stats_environment
      else
        "development"
      end
    end
  end
end
