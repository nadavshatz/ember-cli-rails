require "ember-cli/dependency_checker"

describe EmberCli::DependencyChecker do
  describe "#check!" do
    it "asserts the presence of node_modules" do
      path_set = build_path_set(
        node_modules: double(exist?: false)
      )

      dependency_checker = EmberCli::DependencyChecker.new(path_set: path_set)

      expect { dependency_checker.check! }.
        to raise_error(EmberCli::DependencyError)
    end

    it "asserts the presence of bower_components" do
      path_set = build_path_set(
        bower_components: double(exist?: false),
      )

      dependency_checker = EmberCli::DependencyChecker.new(path_set: path_set)

      expect { dependency_checker.check! }.
        to raise_error(EmberCli::DependencyError)
    end

    it "asserts the presence of `bower` executable" do
      path_set = build_path_set(
        bower: double(executable?: false)
      )

      dependency_checker = EmberCli::DependencyChecker.new(path_set: path_set)

      expect { dependency_checker.check! }.
        to raise_error(EmberCli::DependencyError)
    end

    it "asserts the `ember-cli` package is installed" do
        ember_cli_package_json_file = double(
          exist?: false,
        )
        path_set = build_path_set(ember_cli_package_json_file: ember_cli_package_json_file)

        dependency_checker = EmberCli::DependencyChecker.new(path_set: path_set)

        expect { dependency_checker.check! }.
          to raise_error(EmberCli::DependencyError)
    end

    context "when `ember-cli` package exists" do
      it "ensures the version is up to date" do
        ember_cli_package_json_file = double(
          exist?: true,
          read: JSON.dump(version: "0.0.0"),
        )
        path_set = build_path_set(ember_cli_package_json_file: ember_cli_package_json_file)

        dependency_checker = EmberCli::DependencyChecker.new(path_set: path_set)

        expect { dependency_checker.check! }.
          to raise_error(EmberCli::DependencyError)
      end
    end

    it "asserts the `ember-cli-rails-addon` is installed" do
        addon_package_json_file = double(
          exist?: false,
        )
        path_set = build_path_set(addon_package_json_file: addon_package_json_file)

        dependency_checker = EmberCli::DependencyChecker.new(path_set: path_set)

        expect { dependency_checker.check! }.
          to raise_error(EmberCli::DependencyError)
    end

    context "when `ember-cli-rails-addon` package exists" do
      it "ensures the version is up to date" do
        addon_package_json_file = double(
          exist?: true,
          read: JSON.dump(version: "0.0.0"),
        )
        path_set = build_path_set(addon_package_json_file: addon_package_json_file)

        dependency_checker = EmberCli::DependencyChecker.new(path_set: path_set)

        expect { dependency_checker.check! }.
          to raise_error(EmberCli::DependencyError)
      end
    end

    def build_path_set(**options)
      node_modules = double(exist?: true)
      bower_components = double(exist?: true)
      bower = double(executable?: true)
      ember_cli_package_json_file = double(
        exist?: true,
        read: JSON.dump(version: "1.13.0"),
      )
      addon_package_json_file = double(
        exist?: true,
        read: JSON.dump(version: "0.0.13"),
      )

      double({
        bower: bower,
        node_modules: node_modules,
        bower_components: bower_components,
        ember_cli_package_json_file: ember_cli_package_json_file,
        addon_package_json_file: addon_package_json_file,
      }.merge(options))
    end
  end
end
