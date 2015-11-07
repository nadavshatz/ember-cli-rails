module EmberCli
  class PathSet
    def self.define_path(name, &definition)
      define_method name do
        ivar = "@_#{name}_path"
        if instance_variable_defined?(ivar)
          instance_variable_get(ivar)
        else
          instance_exec(&definition).tap{ |value| instance_variable_set ivar, value }
        end
      end
    end

    def initialize(app:, rails_root:, ember_cli_root:, environment:, configuration:)
      @app = app
      @configuration = configuration
      @rails_root = rails_root
      @environment = environment
      @ember_cli_root = ember_cli_root
    end

    define_path :root do
      path = app_options.fetch(:path){ default_root }
      pathname = Pathname.new(path)
      if pathname.absolute?
        pathname
      else
        rails_root.join(path)
      end
    end

    define_path :tmp do
      root.join("tmp").tap(&:mkpath)
    end

    define_path :log do
      rails_root.join("log", "ember-#{app_name}.#{environment}.log")
    end

    define_path :dist do
      ember_cli_root.join("apps", app_name).tap(&:mkpath)
    end

    define_path :assets do
      ember_cli_root.join("assets").tap(&:mkpath)
    end

    define_path :applications do
      rails_root.join("public", "_apps").tap(&:mkpath)
    end

    define_path :gemfile do
      root.join("Gemfile")
    end

    define_path :tests do
      dist.join("tests")
    end

    define_path :node_modules do
      root.join("node_modules")
    end

    define_path :bower_components do
      root.join("bower_components")
    end

    define_path :package_json_file do
      root.join("package.json")
    end

    define_path :addon_package_json_file do
      node_modules.join("ember-cli-rails-addon", "package.json")
    end

    define_path :ember_cli_package_json_file do
      node_modules.join("ember-cli", "package.json")
    end

    define_path :ember do
      node_modules.join(".bin", "ember").tap do |path|
        unless path.executable?
          fail DependencyError.new <<-MSG.strip_heredoc
            No local ember executable found. You should run `npm install`
            inside the #{app_name} app located at #{root}
          MSG
        end
      end
    end

    define_path :lockfile do
      tmp.join("build.lock")
    end

    define_path :build_error_file do
      tmp.join("error.txt")
    end

    define_path :tee do
      fetch_path_or_default(:tee_path)
    end

    define_path :bower do
      fetch_path_or_default(:bower_path)
    end

    define_path :npm do
      fetch_path_or_default(:npm_path)
    end

    define_path :bundler do
      fetch_path_or_default(:bundler_path)
    end

    private

    attr_reader :app, :configuration, :ember_cli_root, :environment, :rails_root

    delegate :name, :options, to: :app, prefix: true

    def fetch_path_or_default(name)
      path = app_options.fetch(name) { configuration.public_send(name) }

      Pathname(path)
    end

    def default_root
      rails_root.join(app_name)
    end
  end
end
