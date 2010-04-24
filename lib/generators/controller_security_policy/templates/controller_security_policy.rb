require 'yaml'
class ControllerSecurityPolicy
  class SecurityTransgression < StandardError ; end
  
  def self.filter(controller)
    roles = (security_policy[controller.class.to_s] || {}).values_at(
      controller.params[:action].to_s, 'default'
    ).compact.first
    
    if roles.include?('allow')
      return
    end
    
    # implement your application-specific user filtering logic here:
    # if (controller.current_user.roles.collect{|r| r.role_name} & roles).size > 0
    #   return
    # end
    
    #default deny
    raise SecurityTransgression.new
  end
  
  def self.security_policy
    YAML.load(File.join(Rails.root, 'config', 'controller_security_policy.yml'))
  end
end