# Melai

Melai is a command-line tool to create software package repositories for
APT and YUM package management tools.

## Installation
This tool is a standalone tool, and should be installed wither via RubyGems:

    $ gem install melai

If you'd rather install dependencies and install from source:

    $ bundle install && rake install

## Usage

### Requirements
Some prerequisites are needed, and exist currently on Debian/Ubuntu based distros.

* `apt-ftparchive` (Debian-style packages) - `sudo apt-get install apt-utils`
* `createrepo` (RedHat-style packages) - `sudo apt-get install createrepo`

Both of these external tools are needed to build the required repo metadata.

NOTE: This process cannot be run on RedHat/CentOS yet - as they do not have the
tools to work with Debian-style packages.

## Execution

An example:

    melai -r newrepo create -p sourcepackages -u "http://mypackageserver.com/myrepo"

Another way is to initialize a config, and use that:

    melai -r newrepo initconfig

This will create a file named `~/.melai.rc`. Edit it to contain your values:

    ---
    :help: false
    :r: newrepo
    :repos-path: newrepo
    commands:
      :create:
        :pkgs-path: sourcepackages
        :url-root: "http://mypackageserver.com/myrepo"
      :list: {}
      :destroy: {}
      :p: tmpfoo
      :pkgs-path: tmpfoo
      :u: "http://mypackageserver.com/myrepo"
      :url-root: "http://mypackageserver.com/myrepo"
    :list: {}
    :destroy: {}

Then you can run `melai create` with no arguments.
See [here](https://github.com/davetron5000/gli/wiki/Config) for more details.

## Contributing

1. Fork it
1. Create your feature branch (`git checkout -b my-new-feature`)
1. Test your changes (`rake test`)
1. Commit your changes (`git commit -am 'Added some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create new Pull Request
