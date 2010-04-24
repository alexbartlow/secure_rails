require 'generators/base'
module Security
  class ModelGenerator < Security::GeneratorBase
    argument :model, :banner => "User"

    def install_security_policy
      template(
        'model.rb',
        "lib/security/models/#{model.underscore}.rb"
      )
    end
  end
end