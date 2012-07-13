require 'erb'
require 'tempfile'
require 'mixlib/shellout'
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

    def repo_template(metadata, repositories_path, url_root)
      repository_path = metadata[:repository_path]
      case repository_path
      when /redhat/
        source = "redhat.repo.erb"
        target = "10gen.repo"
        url_path = File.join(metadata[:repository_prefix], metadata[:variant], metadata[:arch])
      else
        source = "debian.list.erb"
        target = "10gen.list"
        url_path = File.join(metadata[:repository_prefix])
      end

      here = File.dirname(__FILE__)
      template = ERB.new(File.read(File.join(here, "..", "..", "templates", source)))
      output = File.new(File.join(repository_path, target), "w")
      output.write(template.result(binding))
    end

    def update_repo_metadata(metadata, repositories_path, packages_path)
      repository_path = metadata[:repository_path]

      # e.g /data/packages/cache/debian-sysvinit/dists/
      cache_path = File.join(packages_path, "cache", metadata[:repository_prefix])
      ensure_directory(cache_path)

      case repository_path
      when /redhat/
        begin
          # e.g. repo/redhat/2.0/x86_64/
          variant_dir = File.join(repositories_path,
            metadata[:repository_prefix],
            metadata[:variant],
            metadata[:arch])

          shell_out("createrepo --pretty -c #{cache_path} #{variant_dir}")
        rescue Exception=>e
          exit_now!("Could not complete createrepo:\n#{e}", 1)
        end

      else
        # Do Debian-style repo builds
        here = File.dirname(__FILE__)
        template = ERB.new(File.read(File.join(here, "..", "..", "templates", "apt-ftparchive.conf.erb")))
        output = Tempfile.new("apt-ftparchive.conf")
        output.write(template.result(binding))
        output.close()

        begin
          # Generates the Packages, Contents files
          shell_out("apt-ftparchive generate #{output.path}")

          # Generate the Release files on stdout
          variant_dir = File.join(repositories_path,
            metadata[:repository_prefix],
            "dists",
            metadata[:variant])

          result = shell_out("apt-ftparchive -c #{output.path} release #{variant_dir}")

          # Dump the Release stdout to a Release file
          release_file = File.join(variant_dir, "Release.new")
          File.open(release_file, "w").write(result.stdout)
          # This ensures that the Release file is not included within itself
          File.rename(release_file, File.join(variant_dir, "Release"))

          # TODO: GPG Sign the Release file

        rescue Exception=>e
          exit_now!("Could not complete apt-ftparchive:\n#{e}", 1)
        end
      end
    end

    private

    def shell_out(command)
      proc = Mixlib::ShellOut.new(command)
      proc.run_command
      proc.error!
      return proc
    end

    def rpm_package_metadata(package_path, repositories_path)
      generate_metadata(package_path, repositories_path, ["os"]) do |variant, arch|
        # Return path segments, relative to repositories_path,
        # necessary to construct a path to the correct directory
        # for RPM packages in the given variant and arch.
        ["redhat", variant, arch, "RPMS"]
      end
    end

    def debian_package_metadata(package_path, repositories_path)
      generate_metadata(package_path, repositories_path, ["dist"]) do |variant, arch|
        # Return path segments, relative to repositories_path,
        # necessary to construct a path to the correct directory
        # for Debian packages in the given variant and arch.
        ["debian-sysvinit", "dists", variant, "10gen", "binary-#{arch}"]
      end
    end

    def ubuntu_package_metadata(package_path, repositories_path)
      generate_metadata(package_path, repositories_path, ["dist"]) do |variant, arch|
        # Return path segments, relative to repositories_path,
        # necessary to construct a path to the correct directory
        # for Ubuntu packages in the given variant and arch.
        ["ubuntu-upstart", "dists", variant, "10gen", "binary-#{arch}"]
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
        path_segments = yield variant, arch
        repository_path = File.join(repositories_path, *path_segments)
        repository_prefix = path_segments[0]

        # Create a symlink from the source file to the destination directories
        package_metadata << {
          :symlink_path => File.join(repository_path, File.basename(package_path)),
          :package_path => package_path,
          :variant => variant,
          :arch => arch,
          :repository_path => repository_path,
          :repository_prefix => repository_prefix
        }
      end

      return package_metadata
    end
  end
end
