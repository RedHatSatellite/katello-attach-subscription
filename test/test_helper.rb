require 'json'
require 'yaml'
require 'katello_attach_subscription'
require 'minitest/autorun'

def read_json_fixture(file)
  json = File.expand_path(File.join('..', 'fixtures', "#{file}.json"), __FILE__)
  JSON.parse(File.read(json))
end

def read_yaml_fixture(file)
  yaml = File.expand_path(File.join('..', 'fixtures', "#{file}.yaml"), __FILE__)
  YAML.load_file(yaml)
end
