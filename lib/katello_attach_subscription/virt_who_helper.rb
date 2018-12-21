module KatelloAttachSubscription
  class VirtWhoHelper
    def self.getnamefromvirtwhohypervisordata(hypervisor_data)
      name = hypervisor_data['name'] || hypervisor_data['uuid']
      name.downcase
    end

    def self.validhypervisordata(hypervisor_hash)
      hypervisor_hash.is_a?(Hash) and
          hypervisor_hash.has_key?("hypervisors") and
          hypervisor_hash["hypervisors"].is_a?(Array) and
          hypervisor_hash["hypervisors"].count > 0
    end

    def self.cleanhypervisorfromrawvirtwho(virtwho_hash)
      cleaned_hash = {}
      # loop every hypervisors entry
      virtwho_hash["hypervisors"].each do |hash_hypervisor|
        # if an entry has valid data push to parsed hypervisor hash
        # check if hypervisor has key facts that contain a valid positive integer value relative the number of socket(s) or hash cluster key
        if hash_hypervisor.is_a?(Hash) and hash_hypervisor.has_key?("facts") and hash_hypervisor["facts"].is_a?(Hash) and ((hash_hypervisor["facts"]["cpu.cpu_socket(s)"].to_i > 0) or (hash_hypervisor["facts"].has_key?("hypervisor.cluster") and hash_hypervisor["facts"]["hypervisor.cluster"]))
          hypervisor_name = self.getnamefromvirtwhohypervisordata(hash_hypervisor)
          # add the single hypervisor hash (contained in hash_hypervisor) to cleaned_hash
          cleaned_hash[hypervisor_name] = hash_hypervisor
        end
      end
      return cleaned_hash
    end

    def self.cleansatellitename(satellite_name, orgid)
      clean_name = satellite_name
      clean_name.slice!(/^virt-who-/)
      clean_name.slice!(/-#{orgid}/)
      return clean_name
    end


    def self.merge_system_virtwho(system, virtwhodata, orgid)
      system_name = cleansatellitename(system['name'], orgid)
      virtwho_entry = virtwhodata[system_name]
      return system unless virtwho_entry
      virtwho_entry.fetch('facts', {}).each do |fact, value|
        fact_name = fact.gsub('.', '::')
        system['facts'] ||= {}
        system['facts'][fact_name] ||= value
      end
      system
    end
  end
end
