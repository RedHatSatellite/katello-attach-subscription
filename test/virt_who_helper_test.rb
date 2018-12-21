require 'test_helper'

class VirtWhoHelperTest < Minitest::Test
  def test_getnamefromvirtwhohypervisordata_uuid
    assert_equal 'theuuid', KatelloAttachSubscription::VirtWhoHelper.getnamefromvirtwhohypervisordata({'uuid' => 'theuuid'})
  end

  def test_getnamefromvirtwhohypervisordata_name
    assert_equal 'thename', KatelloAttachSubscription::VirtWhoHelper.getnamefromvirtwhohypervisordata({'uuid' => 'theuuid', 'name' => 'thename'})
  end

  def test_getnamefromvirtwhohypervisordata_name_downcase
    assert_equal 'thename', KatelloAttachSubscription::VirtWhoHelper.getnamefromvirtwhohypervisordata({'uuid' => 'theuuid', 'name' => 'theNAME'})
  end

  def test_validhypervisordata_valid
    assert KatelloAttachSubscription::VirtWhoHelper.validhypervisordata({'hypervisors' => [{'uuid' => 'theuuid'}]})
  end

  def test_validhypervisordata_invalid
    refute KatelloAttachSubscription::VirtWhoHelper.validhypervisordata({'hypervisors' => []})
  end

  def test_merge_system_virtwho
    host = read_json_fixture('vmware_esx_host')
    virt_who_data = read_json_fixture('vmware_esx_virtwho')
    virt_who_hash = KatelloAttachSubscription::VirtWhoHelper.cleanhypervisorfromrawvirtwho(virt_who_data)
    refute host['facts']
    host = KatelloAttachSubscription::VirtWhoHelper.merge_system_virtwho(host, virt_who_hash, 1)
    assert_equal 'fake_cluster', host['facts']['hypervisor::cluster']
    refute host['facts']['hypervisor.cluster']
  end
end
