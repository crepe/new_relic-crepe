module NewRelic
  module Crepe
    class Version
      MAJOR = 0
      MINOR = 0
      PATCH = 1
      PRE   = 'beta'

      def self.to_s
        [MAJOR, MINOR, PATCH, PRE].join('.')
      end
    end

    VERSION = Version.to_s
  end
end
