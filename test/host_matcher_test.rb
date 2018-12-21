require 'test_helper'

class HostMatcherTest < Minitest::Test
  DUMMY_CONFIG = {
      'hostname' => '.*\.example\.com',
      'facts' => [
          {'name' => 'os::release::full', 'matcher' => 'version', 'value' => '>= 7.4'},
          {'name' => 'cpu::cpu_socket(s)', 'value' => '12'}
      ]
  }

  def test_hostname
    assert KatelloAttachSubscription::HostMatcher.match_hostname('client[0-9]+\.example\.com', 'client42.example.com')
  end

  def test_hostname_wrong
    refute KatelloAttachSubscription::HostMatcher.match_hostname('client[0-9]+\.example\.com', 'server42.example.com')
  end

  def test_type_nil
    assert KatelloAttachSubscription::HostMatcher.match_type(nil, 'sometype')
  end

  def test_type_wrong
    refute KatelloAttachSubscription::HostMatcher.match_type('Guest', 'Hypervisor')
  end

  def test_type_correct
    assert KatelloAttachSubscription::HostMatcher.match_type('Guest', 'Guest')
  end

  def test_type_correct_case
    assert KatelloAttachSubscription::HostMatcher.match_type('GuEst', 'gUEsT')
  end

  def test_version_exact
    assert KatelloAttachSubscription::HostMatcher.match_version('7.0', '7.0')
  end

  def test_version_wrong
    refute KatelloAttachSubscription::HostMatcher.match_version('7.0', '6.0')
  end

  def test_version_atleast
    assert KatelloAttachSubscription::HostMatcher.match_version('>= 7.0', '7.5')
  end

  def test_version_atleast_wrong
    refute KatelloAttachSubscription::HostMatcher.match_version('>= 7.0', '6.5')
  end

  def test_host_rhel_rhv_vm
    host = read_json_fixture('rhel_rhv_vm_host')
    assert KatelloAttachSubscription::HostMatcher.match_host(host, DUMMY_CONFIG)
  end

  def test_host_rhel_kvm_vm
    # this host does not have 12 sockets
    host = read_json_fixture('rhel_kvm_vm_host')
    refute KatelloAttachSubscription::HostMatcher.match_host(host, DUMMY_CONFIG)
  end
end
