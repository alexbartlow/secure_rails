require 'yaml'
module Security
  class AccessControl
    def self.filter(controller)
      controller.apply_security_policy_for(controller.current_user)
    end
  end
end