module KatelloAttachSubscription
  class HostMatcher
    def self.match_host(host, config, options = {})
      host['type'] = KatelloAttachSubscription::FactAnalyzer.system_type(host) unless host['type']
      valid = true
      unless self.match_hostname(config['hostname'], host['name'])
        valid = false
        if options[:verbose]
          puts "VERBOSE: #{host['name']} does not match #{config['hostname']}"
        end
      end
      unless self.match_type(config['type'], host['type'])
        valid = false
        if options[:verbose]
          puts "VERBOSE: #{host['name']} has type '#{host['type']}', not '#{config['type']}'"
        end
      end
      host_facts = host['facts'] || {}
      config.fetch('facts', []).each do |match|
        matcher = match['matcher'] || 'string'
        fact = match['name']
        actual = host_facts[fact]
        expected = match['value']
        unless self.match_matcher(expected, actual, matcher)
          valid = false
          if options[:verbose]
            puts "VERBOSE: #{host['name']} has #{fact}='#{actual}', but we expected '#{expected}'"
          end
        end
      end
      valid
    end

    def self.match_hostname(expected_regexp, hostname)
      self.match_regexp(expected_regexp, hostname)
    end

    def self.match_type(expected_type, host_type)
      self.match_string(expected_type, host_type)
    end

    def self.match_matcher(expected, actual, matcher='string')
      case matcher
      when 'string'
        self.match_string(expected, actual)
      when 'version', 'vercmp'
        self.match_version(expected, actual)
      when 'regexp', 'regex'
        self.match_regexp(expected, actual)
      else
        false
      end
    end

    def self.match_string(expected, actual)
      return true if expected.nil?
      return false if actual.nil?
      expected.to_s.downcase == actual.to_s.downcase
    end

    def self.match_regexp(expected, actual)
      return true if expected.nil?
      return false if actual.nil?
      !!Regexp.new(expected).match(actual)
    end

    def self.match_version(expected, actual)
      return true if expected.nil?
      return false if actual.nil?
      requirement = Gem::Requirement.new(expected)
      version = Gem::Version.new(actual)
      requirement.satisfied_by?(version)
    end
  end
end
