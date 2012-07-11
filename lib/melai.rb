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
    def create(reporoot, srcpkgs)
      # Don't create if there's already something in the directory
      if File.exists?(reporoot)
        exit_now!("Something already exists at #{reporoot}. Exiting.", 1)
      else
        puts "Creating a repository at #{reporoot}."
        ensure_directory(reporoot)

        # Collect all the filenames
        pkgfiles = get_any_package_files(srcpkgs)

        # Run each file individually through the parser and act, based on rules
        symlinks_to_ensure = pkgfiles.map do |file|
          process_package(file, reporoot)
        end

        # Accumulate a Hash keyed by repository filesystem path
        # whose values are hashes of {:need_update => bool, 
        # :arch => String, :variant => String }
        repo_info = Hash.new

        # Create all those symlinks here
        symlinks_to_ensure.flatten.each do |link|
          need_update = ensure_symlink(link[:symlink_name], link[:original_file])
          repo = link[:repo]
          need_update ||= repo_info.key?(repo) && repo_info[repo][:need_update]
          repo_info[repo] = {
            :need_update => need_update, 
            :variant => link[:variant],
            :arch => link[:arch],
            :reporoot => link[:reporoot]
          }
        end

        # Now we have a Hash of all the repo directories that need updating by a value of 'true'
        
        repo_info.each do |repo, info|
          next unless info[:need_update]

          variant = info[:variant]
          arch = info[:arch]
          reporoot = info[:reporoot]
          repo_template(repo, variant, arch, reporoot)
        end
      end
    end

    # List all package files found
    #
    # @param [String] a directory containing the source packages
    # @return [Array] an array of filenames
    def list(srcpkgs)
      get_any_package_files(srcpkgs)
    end

    def update(directory)
      pending
    end

    # Destroy the repository directory completely.
    # This is a glorified `rm -fr repo/` command, with a simple guard.
    #
    # @param [String] the root of repository directory
    def destroy(reporoot)
      if reporoot == "/"
        exit_now!("WTF are you trying to do?", 1)
      else
        puts "Removing the entire #{reporoot}"
        FileUtils.remove_dir reporoot
        puts "It's gone!"
      end
    end
  end
end
