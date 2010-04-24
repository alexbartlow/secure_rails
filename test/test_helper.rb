require 'rubygems'
gem 'activesupport'
gem 'activemodel'
gem 'activerecord'
gem 'mocha'
gem 'sqlite3-ruby'
require 'active_support'
require 'active_support/core_ext'
require 'active_model'
require 'active_record'
require 'mocha'
require 'test/unit'


$: << File.join(File.dirname(__FILE__), '..', 'lib')

ActiveRecord::Base.establish_connection(
  :adapter => "sqlite3",
  :database  => ":memory:"
)
ActiveRecord::Schema.define() do
  create_table :users do |u|
    u.string :name, :email, :status, :role
  end
end


class User < ActiveRecord::Base
  def role_on(user)
    if user == self
      :self
    elsif self.role
      self.role
    else
      :default
    end
  end
end

require 'secure_rails'
ActiveRecord::Base.send :include, SecureRails
require 'security_policy'