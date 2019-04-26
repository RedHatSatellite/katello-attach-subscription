module KatelloAttachSubscription
  class Utils

    # INSTANCE_MULTIPLIER WORKAROUND (BZ 1664614 - https://bugzilla.redhat.com/show_bug.cgi?id=1664614)
    # full explanation of the bug and workaround searching for "I[underscore]MW"
    # list of the sub that has instance_multiplier that had to be 2
    EXCEPTION_SUB = [
      "Red Hat Enterprise Linux Server, Standard (Physical or Virtual Nodes)",
      "Red Hat Enterprise Linux Server, Premium (Physical or Virtual Nodes)",
      "Smart Management",
      "Red Hat Enterprise Linux Extended Life Cycle Support (Physical or Virtual Nodes)",
      "Resilient Storage"
    ].freeze

    def self.search_args(search)
      if search.is_a?(String)
        return "\"#{search}\""
      elsif search.is_a?(Hash)
        args = search.collect do |key, value|
          "#{key}=#{self.search_args(value)}"
        end
        self.search_args(args)
      elsif search.is_a?(Array)
        search.compact.join(' and ')
      else
        search
      end
    end

    def self.merge_subs(current_sub, sub_to_merge, command)
      case command
      when "override"
        merged_sub = sub_to_merge.dup
      else
        if current_sub.nil?
          merged_sub = sub_to_merge.dup
        else
          merged_sub = current_sub.merge(sub_to_merge)
        end
      end
      return merged_sub
    end

    # return the correct number of entitlment to use based on certain factor
    def self.needed_entitlement(host_type, host_socket, sub_details)
      if sub_details['type'] == "STACKED_DERIVED"
        return 0
      end
      if host_type == KatelloAttachSubscription::FactAnalyzer:: GUEST
        return 1
      end
      instance_multiplier = 1
      if EXCEPTION_SUB.include?(sub_details["name"])
        instance_multiplier = 2
      end
      socket_limit = 1
      if sub_details.has_key?("sockets")
        if sub_details["sockets"].to_i > 0
          socket_limit = sub_details["sockets"]
        else
          socket_limit = "NO_LIMIT"
        end
      end
      if socket_limit == "NO_LIMIT"
        return instance_multiplier
      end
      total_subscriptions = instance_multiplier * (host_socket.to_f/host_socket.to_f).ceil
      return total_subscriptions
    end
  end
end
