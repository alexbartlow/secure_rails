require 'rails/generators'

module Security
  class GeneratorBase < Rails::Generators::Base
    def self.source_root
      File.join(File.dirname(__FILE__), 'security', 'templates')
    end
    
    def install_security_file
      copy_file(
        'security.rb',
        'lib/security.rb'
      )
    end
  end
end