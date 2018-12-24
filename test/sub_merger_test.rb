#!/usr/bin/env ruby
require 'yaml'
require_relative '../lib/katello_attach_subscription'

class SubMergerTest

  DUMMY_KEEP_PARSE = {
    "type" => "Physical",
    "host" => {
      'name' => 'physical_example',
      'facts' => {
        "distribution::name" => "Red Hat Server",
        "distribution::version" => "6.1"
      }
    }
  }

  DUMMY_MERGE = {
    "type" => "Physical",
    "host" => {
      'name' => 'physical_example',
      'facts' => {
        "distribution::name" => "Red Hat Client",
        "distribution::version" => "5.2"
      }
    }
  }

  DUMMY_OVERRIDE = {
    "type" => "Physical",
    "host" => {
      'name' => 'physical_example',
      'facts' => {
        "distribution::name" => "Red Hat Client"
      }
    }
  }

  DUMMY_STOP = {
    "type" => "Hypervisor",
    "host" => {
      'name' => 'physical_example',
      'facts' => {
        'hypervisor::cluster' => 'example_cluster'
      }
    }
  }

  DUMMY_NORMAL = {
    "type" => "Hypervisor",
    "host" => {
      'name' => 'physical_example',
      'facts' => {}
    }
  }

  def test_normal_parse
    yaml_sub = readSubsFromYAML()
    parsed_sub = getSubForHost(yaml_sub, DUMMY_NORMAL)
    puts "NORMAL PARSE"
    puts "Expected Sub:"
    p parsed_sub
  end

  def test_stop_parse
    yaml_sub = readSubsFromYAML()
    parsed_sub = getSubForHost(yaml_sub, DUMMY_STOP)
    puts "PARSE STOP"
    puts "Expected Sub:"
    p parsed_sub
  end

  def test_overdrive_parse
    yaml_sub = readSubsFromYAML()
    parsed_sub = getSubForHost(yaml_sub, DUMMY_OVERRIDE)
    puts "PARSE OVERDRIVE"
    puts "Expected Sub:"
    p parsed_sub
  end

  def test_merge_parse
    yaml_sub = readSubsFromYAML()
    parsed_sub = getSubForHost(yaml_sub, DUMMY_MERGE)
    puts "PARSE OVERDRIVE"
    puts "Expected Sub:"
    p parsed_sub
  end

  def test_keep_parse
    yaml_sub = readSubsFromYAML()
    parsed_sub = getSubForHost(yaml_sub, DUMMY_KEEP_PARSE)
    puts "PARSE OVERDRIVE"
    puts "Expected Sub:"
    p parsed_sub
  end

  def readSubsFromYAML
    yaml_file = YAML.load_file('fixtures/merge_sub_file.yaml')
    return yaml_file['sub']
  end

  def getSubForHost(subs, host)
    parsed_final = nil
    subs.each do |single_sub|
      parsed = single_sub['parsed_sub']
      if KatelloAttachSubscription::HostMatcher.match_host(host, single_sub)
        layer_command = single_sub['sub_layer'] || 'stop_parsing'
        parsed_final = KatelloAttachSubscription::Utils.merge_subs(parsed_final, parsed, layer_command)
        if layer_command == 'stop_parsing'
          break
        end
      end
    end
    return parsed_final.clone
  end

end