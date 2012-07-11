# require 'rubygems'
require_relative 'melai/version'
require_relative 'melai/dir_helpers'
require_relative 'melai/package_helpers'
require_relative 'melai/string_helpers'

module Melai
  # 
  # This module is the main module. Creates a class of CommandHandler.
  # Not entirely sure if the code is structured correctly. Might have to
  # rethink module vs class locations, based on inheritance.
  # 
  class CommandHandler

    # Creates a symlink-based repository structure
    #
    # @param [String] a directory to build into
    # @param [String] a directory containing the source packages
    def create(repositories_path, packages_path)
      # Don't create if there's already something in the directory
      if File.exists?(repositories_path)
        exit_now!("Something already exists at #{repositories_path}. Exiting.", 1)
      else
        puts "Creating a repository at #{repositories_path}."
        ensure_directory(repositories_path)

        # Accumulate a Hash keyed by repository filesystem path
        # whose values are hashes of {:needs_update => bool, 
        # :arch => String, :variant => String }
        repositories = Hash.new

        find_packages(packages_path).each do |package_path|
          package_metadata(package_path, repositories_path).each do |metadata|
            repository_path = metadata[:repository_path]
            needs_update = ensure_symlink(metadata[:symlink_path], metadata[:package_path])

            if repositories.include?(repository_path)
              repositories[repository_path][:needs_update] ||= needs_update
            else
              repositories[repository_path] = {
                :needs_update => needs_update,
                :variant => metadata[:variant],
                :arch => metadata[:arch],
                :repository_path => metadata[:repository_path]
              }
            end
          end
        end

        # Now we have a Hash of all the repo directories that need updating by a value of 'true'
        repositories.each do |repository_path, metadata|
          next unless metadata[:needs_update]

          variant = metadata[:variant]
          arch = metadata[:arch]
          repo_template(repository_path, variant, arch, repositories_path)
        end
      end
    end

    # List all package files found
    #
    # @param [String] a directory containing the source packages
    # @return [Array] an array of filenames
    def list(packages_path)
      find_packages(packages_path)
    end

    def update(directory)
      pending
    end

    # Destroy the repository directory completely.
    # This is a glorified `rm -fr repo/` command, with a simple guard.
    #
    # @param [String] the root of repository directory
    def destroy(repositories_path)
      if repositories_path == "/"
        exit_now!("WTF are you trying to do?", 1)
      else
        puts "Removing the entire #{repositories_path}"
        FileUtils.remove_dir repositories_path
        puts "It's gone!"
      end
    end
  end
end
