require 'fileutils'
require 'capistrano/wizard/capfile_maker'
require 'capistrano/wizard/deploy_maker'
require 'capistrano/wizard/stages_maker'

module Capistrano
  module Wizard
    class ConfigGenerator
      def initialize(options, plugins)
        @options = options
        @plugins = plugins
      end

      def generate
        FileUtils.mkdir_p 'result/config/deploy'
        CapfileMaker.new(@plugins).generate
        DeployMaker.new(deploy).generate
        StagesMaker.new(@options[:stages]).generate
      end

      private

      def deploy
        @options.select do |key|
          [
            :deploy_to,
            :name,
            :repo_url,
            :ruby_manager,
            :ruby_string
          ].include?(key)
        end
      end
    end
  end
end
