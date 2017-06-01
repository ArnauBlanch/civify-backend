class EventsController < ApplicationController
  include Xattachable
  before_action :check_admin
  before_action :fetch_picture

  def create
    @event = Event.new(event_params)
    @event.image = @picture
    @event.save!
    json_response @event, :created
  end

  def event_params
    params.permit(:title, :start_date, :end_date,
                  :description, :number, :coins,
                  :xp, :kind, :image)
  end

  def check_admin
    render json: { message: 'You are not allowed to manage events' }, status: :unauthorized unless current_user.admin?
  end
end
