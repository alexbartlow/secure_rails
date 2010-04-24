require File.join(File.dirname(__FILE__), '..', 'test_helper')
class SecureTest < Test::Unit::TestCase
  def setup
    @user = User.new(:name => "test")
  end
  
  def test_role_on_method_for_default
    assert User.new.role_on(@user)
  end
  
  def test_role_on_method_for_self
    assert_equal(:self, @user.role_on(@user))
  end
  
  def test_secured_for_default_yields_protected_attributes
    assert @user.secured(User.new).metaclass.accessible_attributes
  end
  
  def test_permission_for_default
    @user.secure_update_attributes(User.new, :name => "hacked")
    assert_equal('test', @user.name)
  end
  
  def test_permission_for_self
    @user.secure_update_attributes(@user, :name => "legitimate")
    assert_equal('legitimate', @user.name)
  end
end