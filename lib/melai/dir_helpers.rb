module Melai

  # This module provides some helper methods, specificlally pertaining
  # to directory creation, removal, searching, et al.
  module DirHelpers

    # Get any files with a known package extension
    #
    # @param [String] a directory to evaluate
    # @return [Array] an array of filenmes
    def get_any_package_files(srcpkgs)
      pkgfiles = File.join(srcpkgs, "**", "*.{rpm,deb}")
      foundfiles = Dir.glob(pkgfiles).sort()
    end

    # Ensure a directory exists
    #
    # @param [String] a directory to evaluate
    # @return [Bool] true if the directory was created, false if already exists
    def ensure_directory(directory)
      unless File.directory?(directory)
        FileUtils.mkdir_p(directory)
        return true
      end
      return false
    end

    # Ensure a symlink exists
    #
    # @param [String] symlink_name: /foo/bar/i-am-a-symlink.rpm
    # @param [String] original_file: /baz/i-am-a-real-file.rpm
    # @return [Bool] true if the link was created, false if already exists
    def ensure_symlink(symlink_name, original_file)
      unless File.symlink?(symlink_name)
        ensure_directory(File.dirname(symlink_name))
        File.symlink(original_file, symlink_name)
        return true
      end
      return false
    end
  end
end
