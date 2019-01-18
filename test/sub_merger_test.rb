require 'test_helper'

class SubMergerTest < Minitest::Test

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

  DUMMY_KEEP_PARSE_EXPECTED_SUB = {
    "rhel": [
      "b1a5d251fa4fe598cb947ffc42b9cbed",
      "1337d38747e659ed836548ae6cda7cc2"
    ],
    "smartmanagement": [
      "f180623caa42379bc4518d06c9c9be05"
    ]
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

  DUMMY_MERGE_EXPECTED_SUB = {
    "rhel": [
        "b1a5d251fa4fe598cb947ffc42b9cbed",
        "1337d38747e659ed836548ae6cda7cc2"
    ],
    "smartmanagement": [
      "f180623caa42379bc4518d06c9c9be05"
    ],
    "els": [
      "523af537946b79c4f8369ed39ba78605"
    ]
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

  DUMMY_OVERRIDE_EXPECTED_SUB = {
    "rhel": [
      "bb98d4e9c281b175ea84c517b59308ea"
    ],
    "smartmanagement": [
      "af03af10d57b7b17f26a0130562d6b6e"
    ]
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

  DUMMY_STOP_EXPECTED_SUB = {
    "rhel": [
      "d2e16e6ef52a45b7468f1da56bba1953",
      "e78f5438b48b39bcbdea61b73679449d",
      "a98931d104a7fb8f30450547d97e7ca5"
    ],
    "els": [
      "7f9a983a540e00931a69382161bdd265"
    ],
    "smartmanagement": [
      "439a7d9b0548adbedcce838e37e84ba1"
    ]
  }


  DUMMY_NORMAL = {
    "type" => "Hypervisor",
    "host" => {
      'name' => 'physical_example',
      'facts' => {}
    }
  }

  DUMMY_NORMAL_EXPECTED_SUB = {
    "rhel": [
      "d2e16e6ef52a45b7468f1da56bba1953",
      "e78f5438b48b39bcbdea61b73679449d",
      "a98931d104a7fb8f30450547d97e7ca5"
    ],
    "els": [
      "7f9a983a540e00931a69382161bdd265"
    ],
    "smartmanagement": [
      "439a7d9b0548adbedcce838e37e84ba1"
    ]
  }


  def test_normal_parse
    yaml = read_yaml_fixture('merge_sub_file')
    parsed_sub = getSubForHost(yaml['sub'], DUMMY_NORMAL)
    assert_equal DUMMY_NORMAL_EXPECTED_SUB, parsed_sub
  end

  def test_stop_parse
    yaml_sub = read_yaml_fixture('merge_sub_file')
    parsed_sub = getSubForHost(yaml['sub'], DUMMY_STOP)
    assert_equal DUMMY_STOP_EXPECTED_SUB, parsed_sub
  end

  def test_overdrive_parse
    yaml_sub = read_yaml_fixture('merge_sub_file')
    parsed_sub = getSubForHost(yaml['sub'], DUMMY_OVERRIDE)
    assert_equal DUMMY_OVERRIDE_EXPECTED_SUB, parsed_sub
  end

  def test_merge_parse
    yaml_sub = read_yaml_fixture('merge_sub_file')
    parsed_sub = getSubForHost(yaml['sub'], DUMMY_MERGE)
    assert_equal DUMMY_MERGE_EXPECTED_SUB, parsed_sub
  end

  def test_keep_parse
    yaml_sub = read_yaml_fixture('merge_sub_file')
    parsed_sub = getSubForHost(yaml['sub'], DUMMY_KEEP_PARSE)
    assert_equal DUMMY_KEEP_PARSE_EXPECTED_SUB, parsed_sub
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
