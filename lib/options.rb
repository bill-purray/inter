require 'optparse'
require 'yaml'

DEFAULT_CONFIG = "config.yaml"
CONFIG_PATH    = "#{File.expand_path("../config", Dir.pwd)}/#{DEFAULT_CONFIG}"
DATA_STORE     = File.expand_path("../data", Dir.pwd) 

def get_options
  ARGV << '-h' if ARGV.empty?

  options = {}
  options[:config] = CONFIG_PATH
  options[:data_store] = DATA_STORE

  parser = OptionParser.new do |opts|
    opts.banner = "Usage: {executable} -p PROJECT"

    opts.on('-p', '--project Project', 'Project') do |project|
      options[:project] = project
    end

    opts.on('-c', '--config path/to/config', 'Override default config') do |config|
      options[:config] = config
    end

    opts.on('-d', '--data path/to/data_store', 'Override default data store') do |data_store|
      options[:data_store] = data_store
    end

    opts.on_tail('-h', '--help', 'Help message') do
      puts(opts)
      exit
    end
  end

  parser.parse!

  options
end

# Verify config file and data_store directory exist
def verify_options(opts)
  unless opts[:config] && File.exist?(opts[:config])
    raise ArgumentError.new("Must specify a config file that exists: #{opts[:config]}")
  end

  unless opts[:data_store] && File.directory?(opts[:data_store])
    raise ArgumentError.new("Must specify a data directory that exists: #{opts[:data_store]}")
  end
end

# Get config and verify project exists
def get_config(opts)
  project = opts[:project].to_sym
  config = YAML.load_file(opts[:config])

  unless config.has_key?(project)
    puts "ERROR!! INVALID PROJECT: #{project}"
    raise OptionParser::InvalidArgument
  end

  config
end
