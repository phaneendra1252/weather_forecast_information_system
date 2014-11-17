class Ability

  include CanCan::Ability

  def initialize(user)
    user ||= User.new # guest user
    if user.role? :admin
      can :manage, :all
      cannot :destroy, User, id: user.id
    elsif user.role? :moderator
      can :read, :all
    else
      can :read, :all
    end
  end

end
