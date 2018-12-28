module KatelloAttachSubscription
  class Utils
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
      if not current_sub.nil?
        current = current_sub.clone
      else
        current = {}
      end
      new_sub = sub_to_merge.clone
      case command
      when "override"
        current = new_sub
      else
        if current.nil?
          current = new_sub
        else
          current.merge!(new_sub)
        end
      end
      return current.clone
    end
  end
end
