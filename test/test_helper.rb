require 'json'
require 'katello_attach_subscription'
require 'minitest/autorun'

def read_json_fixture(file)
  json = File.expand_path(File.join('..', 'fixtures', "#{file}.json"), __FILE__)
  JSON.parse(File.read(json))
end
