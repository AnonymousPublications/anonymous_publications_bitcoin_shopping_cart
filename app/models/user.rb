class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :role_ids, :as => :admin
  attr_accessible :name, :email, :password, :password_confirmation, :remember_me, :confirmed_at
  attr_accessor :email_confirmation # this isn't used, just lazily bypassing an error
  
  has_many :addresses
  has_many :sales
  has_many :bitcoin_payments
  
  def self.random_string(len)
    password = ""
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a 
    
    1.upto(len) { |i| password << chars[rand(chars.size-1)]}
    
    space = rand(len-1)
    password[space] = ("0".."9").to_a[rand(9)]  # ensure there's number and letter
    space += 1
    space = 0 if space == len
    password[space] = ("a".."z").to_a[rand(22)]
    
    return password
  end
  
  def self.create_instant_user(user)
    @generated_password = User.random_string(8) + "1a"
    u = User.new(:email => user[:email], :password => @generated_password, :password_confirmation => @generated_password)
    
    flash = u.errors if u.invalid?
    u
  end
  
  
  def has_paid_purchases?
    (self.sales.where('receipt_confirmed is not NULL').count > 0) or (self.sales.select{|s| s.technically_paid?}.count > 0)
  end
  
  # has_purchases_lacking_confirmation?
  def has_purchases_lacking_confirmation?
    self.sales.where(:receipt_confirmed => nil).count > 0
  end
  
  # has_purchases_lacking_all_payment_evidence?
  def has_purchases_lacking_all_payment_evidence?
    n_purchases_unpaid = 0
    self.sales.each do |sale|
      n_purchases_unpaid += 1 if !sale.technically_paid? and !sale.receipt_confirmed
    end
    n_purchases_unpaid > 0
  end
  
  alias :has_unpaid_purchases? :has_purchases_lacking_all_payment_evidence?

 
  def code_names
    self.addresses.map { |a| a.code_name }
  end
  
  def show_shopping_clutter?
    !hide_shopping_clutter?
  end
  
  def hide_shopping_clutter?
    has_role? :downloader or has_role? :shipping
  end
  
  def team_member?
    has_role?(:admin) or has_role?(:downloader) or has_role?(:shipping)
  end
  
end
