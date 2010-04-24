require 'generators/base'

module Security
  class ControllerGenerator < Security::GeneratorBase
    argument :controller, :banner => "UsersController"
    
    def install_security_policy
      copy_file(
        'access_control.rb',
        'lib/security/access_control.rb'
      )
      template(
        'controller.rb',
        "lib/security/controllers/#{controller.underscore}.rb"
      )
    end
  end
end