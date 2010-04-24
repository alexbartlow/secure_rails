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
  
  def test_permission_for_default
    @user.secure_update_attributes(User.new, :name => "hacked")
    assert_equal('test', @user.name)
  end
  
  def test_permission_for_self
    @user.secure_update_attributes(@user, :name => "legitimate")
    assert_equal('legitimate', @user.name)
  end
  
  def test_permission_for_admin
    admin = User.new(:role => :admin)
    @user.secure_update_attributes(admin, :name => "legitimate")
    assert_equal('legitimate', @user.name)
  end
  
  def test_validations_for_admin
    admin = User.new(:role => :admin)
    @user.secure_update_attributes(admin, :status => "banned_forever")
    assert !@user.valid?, "Validations should take effect on security hole"
  end
  
  def test_validations_for_superadmin
    admin = User.new(:role => :super_admin)
    @user.secure_update_attributes(admin, :status => "banned_forever")
    assert @user.valid?, "Deeply nested permissions should work - " << 
    " also should apply included permissions before local ones"
  end
end