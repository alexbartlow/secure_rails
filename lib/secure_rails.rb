class Object
  def metaclass ; class << self ; self ; end ; end
end

module SecureRails
  def self.included(base)
    base.send :class_inheritable_accessor, :security_policies
    base.class_eval do
      def remove_attributes_protected_from_mass_assignment_with_metaclass(attributes)
        safe_attributes =
          if self.metaclass.accessible_attributes.nil? && self.metaclass.protected_attributes.nil?
            attributes.reject { |key, value| attributes_protected_by_default.include?(key.gsub(/\(.+/, "")) }
          elsif self.metaclass.protected_attributes.nil?
            attributes.reject { |key, value| !self.metaclass.accessible_attributes.include?(key.gsub(/\(.+/, "")) || attributes_protected_by_default.include?(key.gsub(/\(.+/, "")) }
          elsif self.metaclass.accessible_attributes.nil?
            attributes.reject { |key, value| self.metaclass.protected_attributes.include?(key.gsub(/\(.+/,"")) || attributes_protected_by_default.include?(key.gsub(/\(.+/, "")) }
          else
            raise "Declare either attr_protected or attr_accessible for #{self.metaclass}, but not both."
          end

        removed_attributes = attributes.keys - safe_attributes.keys

        if removed_attributes.any?
          log_protected_attribute_removal(removed_attributes)
        end

        remove_attributes_protected_from_mass_assignment_without_metaclass(
          safe_attributes
        )
      end
      
      alias_method_chain :remove_attributes_protected_from_mass_assignment, :metaclass
    end
    base.security_policies = {}
    base.send :include, SecureRails::InstanceMethods
  end
  module InstanceMethods
    def secure_update_attributes(auth, attrs)
      self.secured(auth).update_attributes(attrs)
    end
  
    def apply_security_policy_for(auth)
      proc = self.class.
        security_policies[auth.role_on(self)].
        apply(self)
    end
  
    def secured(auth)
      self.apply_security_policy_for(auth)
      self
    end
  end
  
  class PolicyBuilder
    def initialize(base)
      @base = base
    end
    
    def policy(name, opts = {}, &block)
      @base.security_policies ||= {}
      @base.security_policies[name] = SecureRails::SecurityPolicy.new(opts, block)
    end
  end
  
  class SecurityPolicy
    def initialize(opts, block)
      @opts, @block = opts, block
    end
    
    def apply(object)
      if @opts[:include]
        object.class.security_policies[@opts[:include]].apply(object)
      end
      
      object.metaclass.class_eval &@block
    end
  end
end

def Secure(klass, &block)
  block[SecureRails::PolicyBuilder.new(klass)]
end