require 'erb'
require_relative 'dir_helpers'
require_relative 'string_helpers'

module Melai

  # This module provides some package helper methods
  module PackageHelpers

    def root
      File.expand_path '../..', __FILE__
    end

    def process_rpm_package(file, reporoot)
      generate_symlinks(file, reporoot, "redhat", ["os"]) do |root, variant, arch|
        # return the fullpath
        File.join(reporoot, root, variant, arch, "RPMS")
      end
    end

    def process_debian_package(file, reporoot)
      generate_symlinks(file, reporoot, "debian-sysvinit/dists", ["dist"]) do |root, variant, arch|
        # return the fullpath
        File.join(reporoot, root, variant, "10gen", "binary-#{arch}")
      end
    end

    def process_ubuntu_package(file, reporoot)
      generate_symlinks(file, reporoot, "ubuntu-upstart/dists", ["dist"]) do |root, variant, arch|
        # return the fullpath
        File.join(reporoot, root, variant, "10gen", "binary-#{arch}")
      end
    end

    def repo_template(repo, variant, arch, reporoot)
      case reporoot
      when "redhat"
        source = "redhat.repo.erb"
        target = "10gen.repo"
      else
        source = "debian.list.erb"
        target = "10gen.list"
      end
      
      template = ERB.new(File.read(File.join(root, "..", "templates", source)))
      output = File.new(File.join(repo, target), "w")
      output.write(template.result(binding))
    end

    private

    def generate_symlinks(file, reporoot, root, variants)
      # Since we want to provide both a 'base' variant and a version-specific
      # one, we build an array of variants based on the the version maj.min
      version, dist = get_version_from_filename(file)
      arch = get_arch_from_filename(file)

      variants << dist

      symlinks = []
      variants.each do |variant|
        # This is where the link will end up
        fullpath = yield root, variant, arch
      
        # Create a symlink from the source file to the destination directories
        symlinks << {
          :symlink_name => File.join(fullpath, File.basename(file)),
          :original_file => file,
          :variant => variant,
          :arch => arch,
          :repo => fullpath,
          :reporoot => root
        }
      end

      return symlinks
    end


        
    # 
    # def process_rpm_package(file, reporoot)
    #   # Begin constructing the paths needed for this file
    #   # It's an RPM, we know to create it in /redhat/
    #   root = "redhat"
    # 
    #   # Since we want to provide both a 'base' variant and a version-specific
    #   # one, we build an array of variants based on the the version maj.min
    #   variants = ["os"]
    #   version, dist = get_version_from_filename(file)
    #   arch = get_arch_from_filename(file)
    # 
    #   variants << dist
    # 
    #   # Ensure the directory for this file exists.
    #   # This should end up looking like:
    #   # repo/redhat/os/i686/RPMS/
    #   # repo/redhat/2.0/i686/RPMS/
    #   symlinks = []
    #   variants.each do |variant|
    #     # This is where the link will end up
    #     fullpath = File.join(reporoot, root, variant, arch, "RPMS")
    # 
    #     # Create a symlink from the source file to the destination directories
    #     symlinks << {
    #       :name => File.join(fullpath, File.basename(file)),
    #       :file => file
    #     }
    #   end
    # 
    #   return symlinks
    # end

  end
end
