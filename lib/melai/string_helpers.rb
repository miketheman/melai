require 'versionomy'

module Melai

  # This module provides some string helper methods
  module StringHelpers

    # Find the arch name within a filename
    #
    # @params [String] A filename
    # @return [String] the arch name
    def get_arch_from_filename(filename)
      case
      when matched = filename.match(/(i686|x86_64|i386|amd64)/)
        arch = matched[0]
      else
        return 'unknown'
      end
    end

    # Find the version within a filename
    #    
    # @params [String] A filename
    # @return [Object] the version object, Versionomy-style
    # @return [String] The Major + Minor versions
    def get_version_from_filename(filename)
      version = Versionomy.parse(/(\d+)\.(\d+)\.(\d+)/.match(filename).to_s)
      # TODO: If we start packaging prerelease/rc packages, try:
      # (\d+)\.(\d+)\.(\d+)(?:-[^\.]+)?
      dist = [version.major, version.minor].join(".")
      return version, dist
    end

    # TODO: needs work, currently unused
    def get_unstable_from_filename(filename)
      unstable = /unstable/.match(filename)
      return unstable
    end
  end
end
