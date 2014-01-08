module Capistrano
  module Wizard
    class DeployMaker
      include Helpers::Template

      def initialize(options)
        @options = options
      end

      def generate
        make_template "templates/deploy.rb.erb", "result/config/deploy.rb"
      end
    end
  end
end
