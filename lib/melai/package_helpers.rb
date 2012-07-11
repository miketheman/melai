require 'erb'
require_relative 'dir_helpers'
require_relative 'string_helpers'

module Melai

  # This module provides some package helper methods
  module PackageHelpers

    # Return an array of package metadata hashes. Each
    # array element describes a particular repository
    # that this package should be a member of.
    def package_metadata(package_path, repositories_path)
      case File.extname(package_path)
      when '.rpm'
        return rpm_package_metadata(package_path, repositories_path)
      when '.deb'
        if File.fnmatch('*ubuntu*', package_path)
          return ubuntu_package_metadata(package_path, repositories_path)
        else File.fnmatch('*debian*', package_path)
          return debian_package_metadata(package_path, repositories_path)
        end
      end
    end

    def repo_template(repository_path, variant, arch, repositories_path)
      case repository_path
      when /redhat/
        source = "redhat.repo.erb"
        target = "10gen.repo"
      else
        source = "debian.list.erb"
        target = "10gen.list"
      end

      baseurl = repository_path.slice(
        repositories_path.length + 1,
        repository_path.length - repositories_path.length)

      here = File.dirname(__FILE__)
      template = ERB.new(File.read(File.join(here, "..", "..", "templates", source)))
      output = File.new(File.join(repository_path, target), "w")
      output.write(template.result(binding))
    end


    private

    def rpm_package_metadata(package_path, repositories_path)
      generate_metadata(package_path, repositories_path, ["os"]) do |variant, arch|
        File.join(repositories_path, "redhat", variant, arch, "RPMS")
      end
    end

    def debian_package_metadata(package_path, repositories_path)
      generate_metadata(package_path, repositories_path, ["dist"]) do |variant, arch|
        File.join(repositories_path, "debian-sysvinit/dists", variant, "10gen", "binary-#{arch}")
      end
    end

    def ubuntu_package_metadata(package_path, repositories_path)
      generate_metadata(package_path, repositories_path, ["dist"]) do |variant, arch|
        File.join(repositories_path, "ubuntu-upstart/dists", variant, "10gen", "binary-#{arch}")
      end
    end

    def generate_metadata(package_path, repositories_path, variants)
      # Since we want to provide both a 'base' variant and a version-specific
      # one, we build an array of variants based on the the version maj.min
      version, dist = get_version_from_filename(package_path)
      arch = get_arch_from_filename(package_path)

      variants << dist

      package_metadata = []
      variants.each do |variant|
        # This is where the link will end up
        repository_path = yield variant, arch

        # Create a symlink from the source file to the destination directories
        package_metadata << {
          :symlink_path => File.join(repository_path, File.basename(package_path)),
          :package_path => package_path,
          :variant => variant,
          :arch => arch,
          :repository_path => repository_path
        }
      end

      return package_metadata
    end
  end
end
