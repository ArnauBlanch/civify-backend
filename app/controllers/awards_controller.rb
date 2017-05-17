# Awards controller class
class AwardsController < ApplicationController
  before_action :fetch_picture, only: [:create, :update]

  # GET /awards
  # GET /users/:user_auth_token/offered_awards
  def index
    if params[:user_auth_token]
      set_user
      json_response @user.offered_awards
    else
      json_response Award.all
    end
  end

  # GET /awards/:award_auth_token
  def show
    set_award
    json_response @award
  end

  # POST /user/:user_auth_token/offered_awards
  def create
    set_user
    @award = @user.offered_awards.build(award_params)
    @award.picture = @picture if @picture
    @award.save!
    head :created
  end

  # PUT /awards/:award_auth_token
  # PATCH /awards/:award_auth_token
  def update
    set_award
    @award.picture = @picture if @picture
    @award.update!(award_params)
    json_response @award
  end

  # DELETE /awards/:award_auth_token
  def destroy
    set_award
    @award.destroy
    head :no_content
  end

  private

  def award_params
    params.permit(:title, :description, :price,
                  :picture)
  end

  def fetch_picture
    @picture = parse_image_data(params[:picture]) if params[:picture]
  end

  def parse_image_data(image_data)
    content_type = image_data[:content_type]
    image_file = Paperclip.io_adapters.for("data:#{content_type};base64,#{image_data[:content]}")
    image_file.original_filename = image_data[:filename]
    image_file
  rescue
    json_response({ message: 'Image bad format' }, :bad_request)
  end

  def set_user
    @user = User.find_by!(user_auth_token: params[:user_auth_token])
  end

  def set_award
    @award = Award.find_by!(award_auth_token: params[:award_auth_token])
  end
end
