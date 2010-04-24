class Object
  def metaclass ; class << self ; self ; end ; end
end

module SecureRails
  
  class PolicyDeclarationError < StandardError ; end 
  
  class InvalidAuthenticator < ArgumentError ; end
  
  def self.included(base)
    base.send :include, SecureRails::InstanceMethods
  end
  module InstanceMethods
    def secure_update_attributes(auth, attrs)
      self.apply_security_policy_for(auth)
      self.update_attributes(
        secure_remove_protected_attributes(attrs)
      )
    end
    
    def secure_update_attributes!(auth, attrs)
      self.apply_security_policy_for(auth)
      self.update_attributes!(
        secure_remove_protected_attributes(attrs)
      )
    end
    
    def secure_attributes=(auth, attrs)
      self.apply_security_policy_for(auth)
      self.attributes=(
        secure_remove_protected_attributes(attrs)
      )
    end
  
    def apply_security_policy_for(auth)
      unless auth.respond_to?(:role_on)
        raise SecureRails::InvalidAuthenticator.new(
          "You supplied #{auth} to a secure method, but it does not provide a role_on method."
        )
      end
      proc = self.class.
        security_policies[auth.role_on(self)].
        apply(self)
    end
    
    def secure_remove_protected_attributes(attrs)
      
      maa = self.metaclass.accessible_attributes
      mpa = self.metaclass.protected_attributes
      
      safe_attrs = if mpa && maa
        raise SecureRails::PolicyDeclarationError.new("The application of your " <<
          "policies resulted in #{self} having both accessible and protected "   <<
          "attributes. Specify one, but not the other." )
      elsif mpa
        attrs.reject {|key, value| !maa.include?(key.gsub(/\(.+/, ""))}
      elsif maa
        attrs.reject {|key, value| mpa.include?(key.gsub(/\(.+/, ""))}
      else
        attrs
      end

      removed_attributes = attrs.keys - safe_attrs.keys

      if removed_attributes.any?
        log_protected_attribute_removal(removed_attributes)
      end
      safe_attrs
    end
  end
  
  class PolicyBuilder
    def initialize(base, klass)
      @base, @klass = base, klass
    end
    
    def policy(name, opts = {}, &block)
      @base.security_policies ||= {}
      @base.security_policies[name] = @klass.new(opts, block)
    end
  end
  
  class SecurityPolicy
    def initialize(opts, block)
      @opts, @block = opts, block
    end
    
    def apply(object)
      [@opts[:include]].flatten.compact.each do |included|
        object.class.security_policies[included].apply(object)
      end
    end
  end
  
  class ModelSecurityPolicy < SecurityPolicy
    def apply(object)
      super(object)
      object.metaclass.class_eval &@block
    end
  end
  
  class ControllerSecurityPolicy
    def apply(object)
      super(object)
      object.instance_eval &@block
    end
  end
end

def SecureModel(klass, &block)
  klass.send :class_inheritable_accessor, :security_policies
  klass.security_policies = {}
  block[SecureRails::PolicyBuilder.new(klass, SecureRails::ModelSecurityPolicy)]
end

def SecureController(klass, &block)
  klass.send :class_inheritable_accessor, :security_policies
  klass.security_policies = {}
  block[SecureRails::PolicyBuilder.new(klass, SecureRails::ControllerSecurityPolicy)]
end