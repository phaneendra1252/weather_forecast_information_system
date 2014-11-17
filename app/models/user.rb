class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :roles, through: :users_roles
  has_many :users_roles

  accepts_nested_attributes_for :roles

  validates :name, presence: true

  before_save :capitalize_name

  def capitalize_name
    self.name = self.name.titleize
  end

  def user_role_names
    roles.map(&:name)
  end

  def role?(role)
    user_role_names.include? role.to_s
  end

end
