#
#  Copyright 2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
#  Licensed under the Amazon Software License (the "License").
#  You may not use this file except in compliance with the License.
#  A copy of the License is located at
#
#  http://aws.amazon.com/asl/
#
#  or in the "license" file accompanying this file. This file is distributed
#  on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
#  express or implied. See the License for the specific language governing
#  permissions and limitations under the License.

require 'open-uri'
require 'rollbar/rake_tasks'

SAMPLES_DIR = File.dirname(__FILE__)
JAR_DIR = File.join(SAMPLES_DIR, 'jars')
directory JAR_DIR

def get_maven_jar_info(group_id, artifact_id, version)
  jar_name = "#{artifact_id}-#{version}.jar"
  jar_url = "https://repo1.maven.org/maven2/#{group_id.gsub(/\./, '/')}/#{artifact_id}/#{version}/#{jar_name}"
  local_jar_file = File.join(JAR_DIR, jar_name)
  [jar_name, jar_url, local_jar_file]
end

def download_maven_jar(group_id, artifact_id, version)
  jar_name, jar_url, local_jar_file = get_maven_jar_info(group_id, artifact_id, version)
  open(jar_url) do |remote_jar|
    open(local_jar_file, 'w') do |local_jar|
      IO.copy_stream(remote_jar, local_jar)
    end
  end
end

MAVEN_PACKAGES = [
  # (group id, artifact id, version),
  ['com.amazonaws', 'amazon-kinesis-client', '1.2.0'],
  ['com.fasterxml.jackson.core', 'jackson-core', '2.1.1'],
  ['org.apache.httpcomponents', 'httpclient', '4.2'],
  ['org.apache.httpcomponents', 'httpcore', '4.2'],
  ['com.fasterxml.jackson.core', 'jackson-annotations', '2.1.1'],
  ['commons-codec', 'commons-codec', '1.3'],
  ['joda-time', 'joda-time', '2.4'],
  ['com.amazonaws', 'aws-java-sdk', '1.7.13'],
  ['com.fasterxml.jackson.core', 'jackson-databind', '2.1.1'],
  ['commons-logging', 'commons-logging', '1.1.1'],
]

task :download_jars => [JAR_DIR]

MAVEN_PACKAGES.each do |jar|
  _, _, local_jar_file = get_maven_jar_info(*jar)
  file local_jar_file do
    puts "Downloading '#{local_jar_file}' from maven..."
    download_maven_jar(*jar)
  end
  task :download_jars => local_jar_file
end

file "streamer.properties" do
  puts "Generating properties file"
  envname = ENV.fetch("ZOO_STATS_ENV", "development")
  stream_name = "zooniverse-#{envname}"
  application_name = "zoo-event-stats-#{envname}"

  File.open("streamer.properties", "w") do |file|
    file.puts <<-END
executableName = bin/start_stream_reader
streamName = #{stream_name}
applicationName = #{application_name}
AWSCredentialsProvider = DefaultAWSCredentialsProviderChain
processingLanguage = ruby
initialPositionInStream = TRIM_HORIZON
    END
  end
end

desc "Run KCL stream processor"
task :stream => [:download_jars, "streamer.properties"] do |t|
  fail "JAVA_HOME environment variable not set."  unless ENV['JAVA_HOME']

  puts "Running the Zooniverse Stats Kinesis stream processor service..."
  classpath = FileList["#{JAR_DIR}/*.jar"].join(':')
  classpath += ":#{SAMPLES_DIR}"
  ENV['PATH'] = "#{ENV['PATH']}:#{SAMPLES_DIR}"
  commands = %W(
    #{ENV['JAVA_HOME']}/bin/java
    -classpath #{classpath}
    com.amazonaws.services.kinesis.multilang.MultiLangDaemon streamer.properties
  )
  sh *commands
end

desc "Run test suite"
task :test do
  Dir.glob('./test/**/*_test.rb').each { |file| require file }
end

desc "Test rollbar integration"
task :environment do
  Rollbar.configure do |config |
    config.access_token = ENV["ROLLBAR_ACCESS_TOKEN"]
  end
end

desc "Seed ElasticSearch with dev data"
task :seed_es_dev_data do
  Bundler.require(:default, 'development')
  require_relative 'lib/config'
  require_relative 'lib/output/elasticsearch_writer'
  require_relative 'lib/processor'

  outputs = [ Stats::Output::ElasticsearchWriter.new ]
  processor = Stats::Processor.new(outputs)
  events = JSON.parse(File.read('seeds/dev_stream_records.json'))
  processor.process(events)
  puts "\n\nLoaded the event data to local elastic search store"
end