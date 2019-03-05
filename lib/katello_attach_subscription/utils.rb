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
        search.compact.map {|item| item.is_a?(Hash) ? self.search_args(item) : item }.join(' and ')
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
  end
end
