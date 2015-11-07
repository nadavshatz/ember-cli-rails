require "ember-cli/errors"

module EmberCli
  class DependencyChecker
    ADDON_VERSION = "0.0.13"
    EMBER_CLI_VERSIONS = ["~> 0.1.5", "~> 0.2.0", "~> 1.13"]

    def initialize(path_set:)
      @path_set = path_set
    end

    def check!
      assert_directory_exists!(@path_set.node_modules)
      assert_directory_exists!(@path_set.bower_components)
      assert_bower_executable!
      assert_ember_cli_valid!
      assert_addon_valid!
    end

    private

    def assert_directory_exists!(directory)
      unless directory.exist?
        fail DependencyError.new <<-ERROR.strip_heredoc
          EmberCLI app dependencies are not installed. From your Rails application root please run:

            $ bundle exec rake ember:install

          If you do not require Ember at this URL, you can restrict this check using the `enable`
          option in the EmberCLI initializer.
        ERROR
      end
    end

    def assert_bower_executable!
      unless @path_set.bower.executable?
        fail DependencyError.new <<-ERROR.strip_heredoc
          Bower is required by EmberCLI

          Install it with:

              $ npm install -g bower
        ERROR
      end
    end

    def assert_dependency_version!(path, name, versions)
      acceptable_versions = Array(versions)

      unless path.exist?
        fail DependencyError.new <<-ERROR
          EmberCLI Rails requires `#{name}` version `#{acceptable_versions}`

          Please add it to your `package.json` and run

            $ npm install

        ERROR
      end

      current_version = fetch_version(path)

      unless Helpers.match_version?(current_version, acceptable_versions)
        fail DependencyError.new <<-ERROR.strip_heredoc
          EmberCLI Rails requires `#{name}` version `#{acceptable_versions}`

          You have `#{current_version}` installed.

          Please update your `package.json` and run

            $ npm install

        ERROR
      end
    end

    def assert_ember_cli_valid!
      assert_dependency_version!(
        @path_set.ember_cli_package_json_file,
        "ember-cli",
        EMBER_CLI_VERSIONS,
      )
    end

    def assert_addon_valid!
      assert_dependency_version!(
        @path_set.addon_package_json_file,
        "ember-cli-rails-addon",
        ADDON_VERSION,
      )
    end

    def fetch_version(path)
      json = JSON.parse(path.read)

      json["version"]
    end
  end
end
