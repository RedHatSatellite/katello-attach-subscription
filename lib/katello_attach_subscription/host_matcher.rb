module KatelloAttachSubscription
  class HostMatcher
    def self.match_host(host, config, options = {})
      # this method shall test a host (as defined in Foreman)
      # against a config (in most cases a subscription definition)
      #
      # executed checks:
      # 1. does the hostname match the regex defined in the config
      # 2. does the type of the host match the one in the config
      #    if the config does not have a type key, this check is skipped
      # 3. do all (!) facts defined in the config match those on the host
      #    if the config has no facts defined, this check is skipped
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
      # alias for match_regexp
      self.match_regexp(expected_regexp, hostname)
    end

    def self.match_type(expected_type, host_type)
      # alias for match_string
      self.match_string(expected_type, host_type)
    end

    def self.match_matcher(expected, actual, matcher='string')
      # execute one of the match functions, depending on the
      # matcher asked for
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
      # returns true if nothing (nil) is expected
      # returns false if no actual value is provided
      # otherwise does a case-insensitive string comparison
      return true if expected.nil?
      return false if actual.nil?
      expected.to_s.downcase == actual.to_s.downcase
    end

    def self.match_regexp(expected, actual)
      # returns true if nothing (nil) is expected
      # returns false if no actual value is provided
      # otherwise executes a regexp match
      return true if expected.nil?
      return false if actual.nil?
      !!Regexp.new(expected).match(actual)
    end

    def self.match_version(expected, actual)
      # returns true if nothing (nil) is expected
      # returns false if no actual value is provided
      # otherwise checks if actual satisfies a Gem::Requirement of expected
      return true if expected.nil?
      return false if actual.nil?
      requirement = Gem::Requirement.new(expected)
      version = Gem::Version.new(actual)
      requirement.satisfied_by?(version)
    end
  end
end
