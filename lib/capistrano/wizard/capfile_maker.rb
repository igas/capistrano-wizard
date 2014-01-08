module Capistrano
  module Wizard
    class CapfileMaker
      include Helpers::Template

      def initialize(plugins)
        @plugins = plugins
      end

      def generate
        make_template "templates/Capfile.erb", "result/Capfile"
      end
    end
  end
end
