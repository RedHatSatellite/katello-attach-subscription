require "minitest/autorun"
require 'test_helper'

class FactAnalyzerTest < Minitest::Test
  def test_system_type_empty
    assert_equal 'unknown', KatelloAttachSubscription::FactAnalyzer.system_type({}, {})
  end

  def test_system_type_rhel_kvm_vm
    host = read_json_fixture('rhel_kvm_vm_host')
    facts = read_json_fixture('rhel_kvm_vm_facts')
    assert_equal 'guest', KatelloAttachSubscription::FactAnalyzer.system_type(host, facts)
  end

  def test_system_type_rhel_rhv_vm
    host = read_json_fixture('rhel_rhv_vm_host')
    facts = read_json_fixture('rhel_rhv_vm_facts')
    assert_equal 'guest', KatelloAttachSubscription::FactAnalyzer.system_type(host, facts)
  end

  def test_system_type_cisco_blade
    host = read_json_fixture('rhel_cisco_blade_host')
    facts = read_json_fixture('rhel_cisco_blade_facts')
    assert_equal 'physical', KatelloAttachSubscription::FactAnalyzer.system_type(host, facts)
  end

  def test_system_type_dell_poweredge
    host = read_json_fixture('rhel_dell_poweredge_host')
    facts = read_json_fixture('rhel_dell_poweredge_facts')
    assert_equal 'physical', KatelloAttachSubscription::FactAnalyzer.system_type(host, facts)
  end

  def test_system_type_vmware_esx
    host = read_json_fixture('vmware_esx_host')
    facts = read_json_fixture('vmware_esx_facts')
    assert_equal 'hypervisor', KatelloAttachSubscription::FactAnalyzer.system_type(host, facts)
  end

  def test_system_type_from_facts_empty
    assert_nil KatelloAttachSubscription::FactAnalyzer.system_type_from_facts({})
  end

  def test_system_type_from_facts_virt_host_type_kvm
    assert_equal 'guest', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts({'virt::host_type' => 'kvm'})
  end

  def test_system_type_from_facts_virt_host_type_na
    assert_equal 'physical', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts({'virt::host_type' => 'Not Applicable'})
  end

  def test_system_type_from_facts_virt_is_guest
    assert_equal 'guest', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts({'virt::is_guest' => 'true'})
  end

  def test_system_type_from_facts_virt_is_guest_false
    assert_nil KatelloAttachSubscription::FactAnalyzer.system_type_from_facts({'virt::is_guest' => 'false'})
  end

  def test_system_type_from_facts_virt_uuid
    assert_equal 'guest', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts({'virt::uuid' => 'uuid'})
  end

  def test_system_type_from_facts_hypervisor_version
    assert_equal 'hypervisor', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts({'hypervisor::version' => '6.5.0'})
  end

  def test_system_type_from_facts_hypervisor_type
    assert_equal 'hypervisor', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts({'hypervisor::type' => 'VMware ESXi'})
  end

  def test_system_type_from_facts_hypervisor_cluster
    assert_equal 'hypervisor', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts({'hypervisor::cluster' => 'fake_cluster'})
  end

  def test_system_type_from_facts_rhel_kvm_vm
    facts = read_json_fixture('rhel_kvm_vm_facts')
    assert_equal 'guest', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts(facts)
  end

  def test_system_type_from_facts_rhel_rhv_vm
    facts = read_json_fixture('rhel_rhv_vm_facts')
    assert_equal 'guest', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts(facts)
  end

  def test_system_type_from_facts_cisco_blade
    facts = read_json_fixture('rhel_cisco_blade_facts')
    assert_equal 'physical', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts(facts)
  end

  def test_system_type_from_facts_dell_poweredge
    facts = read_json_fixture('rhel_dell_poweredge_facts')
    assert_equal 'physical', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts(facts)
  end

  def test_system_type_from_facts_vmware_esx
    facts = read_json_fixture('vmware_esx_facts')
    assert_equal 'hypervisor', KatelloAttachSubscription::FactAnalyzer.system_type_from_facts(facts)
  end

  def test_system_type_from_host_empty
    host = {}
    assert_nil KatelloAttachSubscription::FactAnalyzer.system_type_from_host(host)
  end

  def test_system_type_from_host_rhel_kvm_vm
    host = read_json_fixture('rhel_kvm_vm_host')
    # this should return guest, but it does not contain the data in the export
    assert_nil KatelloAttachSubscription::FactAnalyzer.system_type_from_host(host)
  end

  def test_system_type_from_host_rhel_rhv_vm
    host = read_json_fixture('rhel_rhv_vm_host')
    # this should return guest, but it does not contain the data in the export
    assert_nil KatelloAttachSubscription::FactAnalyzer.system_type_from_host(host)
  end

  def test_system_type_from_host_rhel_cisco_blade
    host = read_json_fixture('rhel_cisco_blade_host')
    assert_nil KatelloAttachSubscription::FactAnalyzer.system_type_from_host(host)
  end

  def test_system_type_from_host_rhel_dell_poweredge
    host = read_json_fixture('rhel_dell_poweredge_host')
    assert_nil KatelloAttachSubscription::FactAnalyzer.system_type_from_host(host)
  end

  def test_system_type_from_host_vmware_esx
    host = read_json_fixture('vmware_esx_host')
    assert_equal 'hypervisor', KatelloAttachSubscription::FactAnalyzer.system_type_from_host(host)
  end
end
