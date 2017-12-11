class UsersController < ApplicationController
	before_action :logged_in_user, only: [:index, :edit, :update, :destroy]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy
  
   
  api_version "1","2"
  def_param_group :validation do
    param :id, Fixnum,                   :desc => "User id",                          :required => false
    param :name, String,                 :desc => "Username for Signup",              :required => true
    param :password, String,             :desc => "Password for Signup",              :required => true
    param :password_confirmation, String,:desc => "password_confirmation for login",  :required => true
    param :email, /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i,:desc => "email for login",    :required => true
  end

  api :GET ,"/users","This is the index view for all User list which have succefully registered"
  description <<-EOS
    == User description
      it shows the all activated user list with the pagination 
    EOS
   
  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  api :GET ,"/users/:id","Get a user name which we have to show"
  description <<-EOS
    == User description
     it shows micropost for current-user and who are following for the current user
    EOS
  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated?
  end

  api :GET ,"/users/new","Get a new form for create new user"
  description <<-EOS
    == User description
     it returns the new form 
  EOS
  def new
    @user = User.new
  end

  api :POST ,"/users","Save the users"
  param_group :validation
  description <<-EOS
    == User description
      if user is saved after that mail goes to the user mailid, in this mail goes to one link using thid link
        account will be activated. and after that it redirects to the user link

      else it returns the new user form
    EOS
  def create
    @user = User.new(user_params)
    if @user.save
      UserMailer.account_activation(@user).deliver_now
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  api :GET ,"/users/:id/edit" ,"Get a user form which we have to update"
  description <<-EOS
    == User description
      it return the users edit form which we have to update the data of user  
    EOS
  def edit
    @user = User.find(params[:id])
  end

  api :PATCH ,"/users/:id/edit" ,"Update the User"
  param_group :validation
  description <<-EOS
  == User description
    update the user or it redirect to edit form
  EOS
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  api :DELETE ,"/users/:id","Destroy the user"
  description <<-EOS
  == User description
    delete the user and redirect to the user list 
  EOS
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  api :GET ,"/users/:id/following","Show the list of following user"
  description <<-EOS
  == User description
    it show the user and user following list
  EOS
  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  api :GET ,"/users/:id/followers","Show the list of followers user"
  description <<-EOS
  == User description
    it show the user and user follower list
  EOS
  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end


  private

  def user_params
    params.require(:user).permit(:name, :email, :password,:password_confirmation)
  end

  # Confirms a logged-in user.
  def logged_in_user
    unless logged_in?
    	# store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end

    

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_url) unless current_user?(@user)
  end
  # Returns a user's status feed.
  def feed
    Micropost.where("user_id IN (:following_ids) OR user_id = :user_id",
                    following_ids: following_ids, user_id: id)
  end
  # Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user.admin?
  end
end 	 