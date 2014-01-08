require 'erb'

module Capistrano
  module Wizard
    module Helpers
      module Template
        def make_template(source, destination)
          source = File.expand_path(File.join(File.dirname(__FILE__),"..", source))
          File.open(destination, 'wb') { |f| f.write ERB.new(File.binread(source)).result(instance_eval('binding')) }
        end
      end
    end
  end
end
