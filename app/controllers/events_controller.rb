class EventsController < ApplicationController
  include Xattachable
  before_action :needs_admin, except: [:show, :index]
  before_action -> { set_current_user(Event) }, only: [:show, :index]
  before_action :fetch_picture, only: [:create, :update]
  before_action :set_event, only: [:show]

  def create
    @event = Event.new(event_params)
    @event.image = @picture
    save_render! @event
    create_event_progress
  end

  def index
    render_from Event.all.enabled(params[:enabled])
  end

  def show
    render_from @event
  end

  private

  def set_event
    @event = Event.find_by(event_token: params[:event_token])
    render_from message: 'Event does not exists', status: :not_found unless @event
  end

  def event_params
    params.permit(:title, :start_date, :end_date, :description, :number, :coins, :xp, :kind, :image)
  end

  def create_event_progress
    User.all.each do |user|
      user.events_in_progress << @event
    end
  end

end
