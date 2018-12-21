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
  end
end

