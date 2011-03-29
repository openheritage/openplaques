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
  
  validates_presence_of     :username
  validates_length_of       :username,    :within => 3..40
  validates_uniqueness_of   :username

  belongs_to :todo_item

  
  def make_admin
    self.is_admin = true
    self.save!
  end
  

end
