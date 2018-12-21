module KatelloAttachSubscription
  class FactAnalyzer

    GUEST = 'Guest'.freeze
    PHYSICAL = 'Physical'.freeze
    HYPERVISOR = 'Hypervisor'.freeze
    UNKNOWN = 'Unknown'.freeze

    def self.system_type_from_facts(facts)
      if (not facts['virt::host_type'].nil? and facts['virt::host_type'] != 'Not Applicable') or
          (facts['virt::is_guest'] and facts['virt::is_guest'].to_s.downcase != 'false') or
          facts['virt::uuid']
        return GUEST
      end

      if (not facts['virt::host_type'].nil? and facts['virt::host_type'] == 'Not Applicable')
        return PHYSICAL
      end

      if facts['hypervisor::version'] or facts['hypervisor::cluster'] or facts['hypervisor::type']
        return HYPERVISOR
      end
    end

    def self.system_type_from_host(host)
      subsciption_facet = host['subscription_facet_attributes']
      if subsciption_facet
        if not subsciption_facet['virtual_guests'].empty?
          return HYPERVISOR
        end
        if subsciption_facet['virtual_host']
          return GUEST
        end
      end
    end

    def self.system_type(host, facts = nil)
      facts = host['facts'] unless facts
      self.system_type_from_host(host) || self.system_type_from_facts(facts) || UNKNOWN
    end
  end
end
