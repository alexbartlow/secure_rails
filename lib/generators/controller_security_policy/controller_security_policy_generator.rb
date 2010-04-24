require 'rails/generators'

class ControllerSecurityPolicyGenerator < Rails::Generators::Base
  def self.source_root
    File.join(File.dirname(__FILE__), 'templates')
  end
  
  def install_security_policy
    copy_file(
      'controller_security_policy.yml',
      'config/controller_security_policy.yml'
    )
    copy_file(
      'controller_security_policy.rb',
      'lib/security/controller_security_policy.rb'
    )
  end
end