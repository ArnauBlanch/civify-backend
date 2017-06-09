# Awards controller class
class AwardsController < ApplicationController
  include Xattachable
  before_action :fetch_picture, only: [:create, :update]
  before_action -> { needs_admin_or_business('You are not allowed to manage awards') }, except: [:index, :show]

  # GET /awards
  # GET /users/:user_auth_token/offered_awards
  def index
    result = if params[:user_auth_token]
               set_user
               @user.offered_awards.where(visible: true)
             else
               Award.all.where(visible: true)
             end
    render_from result
  end

  # GET /awards/:award_auth_token
  def show
    set_award
    render_from @award
  end

  # POST /user/:user_auth_token/offered_awards
  def create
    set_user
    @award = @user.offered_awards.build(award_params)
    @award.picture = @picture if @picture
    save_render! @award
  end

  # PUT /awards/:award_auth_token
  # PATCH /awards/:award_auth_token
  def update
    set_award
    @award.picture = @picture if @picture
    update_render!(@award, award_params)
  end

  # DELETE /awards/:award_auth_token
  def destroy
    set_award
    destroy_render! @award
  end

  private

  def award_params
    params.permit(:title, :description, :price, :picture)
  end

  def set_user
    @user = User.find_by!(user_auth_token: params[:user_auth_token])
  end

  def set_award
    @award = Award.find_by!(award_auth_token: params[:award_auth_token])
  end
end
