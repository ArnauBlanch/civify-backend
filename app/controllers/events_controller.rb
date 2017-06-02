class EventsController < ApplicationController
  include Xattachable
  before_action :needs_admin, except: [:show, :index]
  before_action :fetch_picture, only: [:create, :update]

  def create
    @event = Event.new(event_params)
    @event.image = @picture
    save_render(@event, :created)
  end

  def event_params
    params.permit(:title, :start_date, :end_date,
                  :description, :number, :coins,
                  :xp, :kind, :image)
  end
end
