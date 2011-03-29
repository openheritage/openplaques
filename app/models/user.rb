require 'digest/sha1'

# This class represents registered users of the website
#
# === Attributes
# * +name+ - The full name of the user.
# * +username+ - The user's unique 'username'.
# * +email+ - The user's e-mail address.
#
# === Associations
# * +plaques+ - The plaques that this user added to the site.
class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me, :username
  
  has_many :plaques
  
#  include Authentication
#  include Authentication::ByPassword
#  include Authentication::ByCookieToken

  validates_presence_of     :username
#  validates_length_of       :username,    :within => 3..40
  validates_uniqueness_of   :username
#  validates_format_of       :username,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

#  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
#  validates_length_of       :name,     :maximum => 100

#  validates_presence_of     :email
#  validates_length_of       :email,    :within => 6..100 #r@a.wk
#  validates_uniqueness_of   :email
#  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message

  belongs_to :todo_item

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :username, :email, :name, :password, :password_confirmation



  # Authenticates a user by their username name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  
  def make_admin
    self.is_admin = true
    self.save!
  end
  
#  def self.authenticate(username, password)
#    return nil if username.blank? || password.blank?
#    u = find_by_username(username.downcase) # need to get the salt
#    u && u.authenticated?(password) ? u : nil
#  end

#  def username=(value)
#    write_attribute :username, (value ? value.downcase : nil)
#  end

#  def email=(value)
#    write_attribute :email, (value ? value.downcase : nil)
#  end

  protected
    


end
