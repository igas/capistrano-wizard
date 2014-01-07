module Capistrano
  module Wizard
    class StagesMaker
      include Helpers::File

      def initialize(stages)
        @stages = stages
      end

      def generate
        @stages.each do |stage|
          @stage = stage
          template "templates/stage.rb.erb", "result/config/deploy/#{stage[:name]}.rb"
        end
      end
    end
  end
end
