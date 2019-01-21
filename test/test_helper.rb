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

def getSubForHost(subs, host)
  parsed_final = nil
  subs.each do |single_sub|
    parsed = single_sub['sub_parsed']
    if KatelloAttachSubscription::HostMatcher.match_host(host, single_sub)
      layer_command = single_sub['sub_layer'] || 'stop_parsing'
      parsed_final = KatelloAttachSubscription::Utils.merge_subs(parsed_final, parsed, layer_command)
      if layer_command == 'stop_parsing'
        break
      end
    end
  end
  return parsed_final
end
