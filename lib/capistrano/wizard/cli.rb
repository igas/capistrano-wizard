require 'optparse'

module Capistrano
  module Wizard
    class CLI
      YES_ANSWERS = ['Y', 'y', 'Yes', 'yes', 'YES', ''].freeze
      RUBY_MANAGERS = [:rvm, :rbenv, :chruby, :''].freeze
      DEFAULT_STAGES = %w[production staging].freeze

      def run
        @ask_for_ruby = true

        opts.banner = "Usage: cap-wizard [options]"
        opts.separator ""
        opts.separator "Specific options:"

        parse_main_info
        parse_ruby_manager
        parse_capistrano_plugins
        parse_common_options

        begin
          opts.parse!
        rescue OptionParser::ParseError => exception
          exception.args.each do |arg|
            unless %w[--name --repo-url --deploy-to].include?(arg)
              $stdout << "Invalid argument: #{arg}\n"
              exit 1
            end
            $stdout << "Missing argument for: #{arg}\n"
          end
        end

        interactive_main_info
        interactive_ruby_manager
        interactive_capistrano_plugins
        interactive_stages

        ConfigGenerator.new(options, plugins).generate

        $stdout << generate_notes(plugins)
      end

      private

      def interactive_stages
        stages = ask("Which stages do you want to use? Default: #{DEFAULT_STAGES.join(', ')}\n > ")
        stages = if stages.empty?
                   DEFAULT_STAGES.dup
                 else
                   stages.split(/[\s,]+/)
                 end
        options[:stages] = []
        stages.each do |stage|
          credentials = ''
          until credentials =~ /\A[^@]+@[^@]+\z/
            credentials = ask("Enter credentials for #{stage} in user@host.com format:\n > ")
          end
          username, host = credentials.split("@")
          options[:stages].push({ name: stage, username: username, host: host})
        end
      end

      def parse_main_info
        opts.on("--name NAME", "Set application name") do |name|
          options[:name] = name
        end

        opts.on("--repo-url URL", "Set repository url") do |url|
          options[:repo_url] = url
        end

        opts.on("--deploy-to PATH", "Set deployment path") do |path|
          options[:deploy_to] = path
        end
      end

      def interactive_main_info
        if blank?(options[:name])
          options[:name] = ask("What is application name? Default: #{File.basename(Dir.getwd)}\n > ")
          options[:name] = File.basename(Dir.getwd) if blank?(options[:name])
        end

        if blank?(options[:repo_url])
          while blank?(options[:repo_url])
            options[:repo_url] = ask("Repo url? Example: git@github.com:user/repo.git\n > ")
          end
        end

        if blank?(options[:deploy_to])
          options[:deploy_to] = ask("What path use for deploy? Default: /var/www/#{options[:name]})\n > ")
          options[:deploy_to] = "/var/www/#{options[:name]}" if blank?(options[:deploy_to])
        end
      end

      def parse_ruby_manager
        opts.on("--skip-ruby-manager", "Don't use ruby manager") do
          @ask_for_ruby = false
        end

        opts.on("--rvm [RUBY_VERSION]", "Use rvm with RUBY_VERSION") do |ruby|
          options[:ruby_manager] = :rvm
          options[:ruby_string] = ruby || ''
          plugins << :rvm
        end

        opts.on("--rbenv [RUBY_VERSION]", "Use rbenv with RUBY_VERSION") do |ruby|
          options[:ruby_manager] = :rbenv
          options[:ruby_string] = ruby || ''
          plugins << :rbenv
        end

        opts.on("--chruby [RUBY_VERSION]", "Use chruby with RUBY_VERSION") do |ruby|
          options[:ruby_manager] = :chruby
          options[:ruby_string] = ruby || ''
          plugins << :chruby
        end
      end

      def interactive_ruby_manager
        if blank?(options[:ruby_manager]) && @ask_for_ruby
          until RUBY_MANAGERS.include?(options[:ruby_manager])
            options[:ruby_manager] = ask("Do you want to use Ruby version manager?\nLeave blank to use system ruby.\nAvailable Ruby version managers:\n - rvm\n - rbenv\n - chruby\n > ").to_sym
          end
          unless options[:ruby_manager].empty?
            options[:ruby_string] = ask("Ruby string\n > ")
          end
          plugins << options[:ruby_manager]
        end
      end

      def parse_capistrano_plugins
        opts.on("--[no-]rails", "Add rails plugin") do |v|
          options[:rails] = v
          options[:bundler] = v
          plugins << :rails if v
        end

        opts.on("--[no-]bundler", "Add bundler plugin (not necessary if rails plugin used)") do |v|
          options[:bundler] = v
          plugins << :bundler if v
        end
      end

      def interactive_capistrano_plugins
        if !options.key?(:rails) && ask?("Add rails plugin? [Y/n]\n > ")
          options[:rails] = true
          options[:bundler] = true
          plugins << :rails
        end

        if !options[:bundler] && ask?("Add bundler plugin? [Y/n]\n > ")
          options[:bundler] = true
          plugins << :bundler
        end
      end

      def parse_common_options
        opts.separator ""
        opts.separator "Common options:"

        opts.on_tail("-v", "--version", "Show version") do
          $stdout << Capistrano::Wizard::VERSION
          $stdout << "\n"
          exit
        end

        opts.on_tail("-h", "--help", "Show help") do
          $stdout << opts
          exit
        end
      end

      def generate_notes(plugins)
        notes = ["Don't forget to add this gems to Gemfile:", "gem 'capistrano'"]
        notes << "gem 'capistrano-rvm'" if plugins.include?(:rvm)
        notes << "gem 'capistrano-rbenv', '~> 2.0'" if plugins.include?(:rbenv)
        notes << "gem 'capistrano-chruby', github: 'capistrano/chruby'" if plugins.include?(:chruby)
        notes << "gem 'capistrano-bundler'" if plugins.include?(:bundler)
        notes << "gem 'capistrano-rails', '~> 1.1'" if plugins.include?(:rails)
        "#{notes.join("\n")}\n"
      end

      def opts
        @opts ||= OptionParser.new
      end

      def options
        @options ||= {}
      end

      def plugins
        @plugins ||= []
      end

      def ask?(prompt)
        $stdout << prompt
        YES_ANSWERS.include?($stdin.gets.strip)
      end

      def ask(prompt)
        $stdout << prompt
        $stdin.gets.strip
      end

      def blank?(opt)
        opt.nil? || opt.empty?
      end
    end
  end
end
