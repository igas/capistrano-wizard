module Capistrano
  module Wizard
    class CapfileMaker
      include Helpers::File

      def initialize(plugins)
        @plugins = plugins
      end

      def generate
        template "templates/Capfile.erb", "result/Capfile"
      end
    end
  end
end
