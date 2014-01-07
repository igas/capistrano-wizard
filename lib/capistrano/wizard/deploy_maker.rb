module Capistrano
  module Wizard
    class DeployMaker
      include Helpers::File

      def initialize(options)
        @options = options
      end

      def generate
        template "templates/deploy.rb.erb", "result/config/deploy.rb"
      end
    end
  end
end
