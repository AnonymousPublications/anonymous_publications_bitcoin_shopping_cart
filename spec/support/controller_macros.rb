module ControllerMacros
  def login_admin
    @request.env["devise.mapping"] = Devise.mappings[:admin]
    r = Role.new
    r.name = "admin"
    r.save
    admin = FactoryGirl.create(:user)
    admin.roles << r
    admin.save
    
    sign_in admin # Using factory girl as an example
  end

  def login_user
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @user = FactoryGirl.create(:user)
    @user.confirm! # or set a confirmed_at inside the factory. Only necessary if you are using the confirmable module
    @address = create_address_for_user(@user)
    @address_alt = create_alt_address_for_user(@user)
    sign_in @user
  end
  
  def create_products
    populate_products
  end
  
end