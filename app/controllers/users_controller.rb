class UsersController < ApplicationController

  def index
    set_users
  end

  def edit
    @user = User.find(params[:id])
    set_roles
  end

  def update
    @user = User.find(params[:id])
    set_roles
    if @user.update(user_params)
      redirect_to "/users", notice: "User record updated successfully"
    else
      render 'users/edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    if @user.destroy
      redirect_to "/users", notice: "User record deleted successfully"
    else
      redirect_to "/users", notice: "User record not deleted because #{user.errors.full_messages.join(", ")}"
    end
  end

  def set_roles
    @roles = Role.all
  end

  def set_users
    @users = User.order(:name)
    @users = Kaminari.paginate_array(@users).page(params[:page]).per(15)
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :role_ids => [])
    end

end
