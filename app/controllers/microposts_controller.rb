class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy


  def_param_group :micro_validation do
    param :id, Fixnum,                   :desc => "micropost id",                          :required => false
    param :micropost, String,                 :desc => "micropost for generate_post",              :required => true
  end
  api! "Create a micropost"
   description <<-EOS
    == User description
      Create a microppost for current user
    EOS
  # api :POST ,"/microposts","create a new Micropost"
  param_group :micro_validation
  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      @feed_items = []
      render 'static_pages/home'
    end
  end
  
  api! "Delete the micropost"
  # api :DELETE ,"/microposts/:id","Delete the post"
   description <<-EOS
  == User description
    delete the micropost for current user
  EOS
  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_to request.referrer || root_url
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content, :picture)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end