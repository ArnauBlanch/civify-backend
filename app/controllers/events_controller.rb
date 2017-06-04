class EventsController < ApplicationController
  include Xattachable
  before_action :needs_admin, except: [:show, :index]
  before_action :fetch_picture, only: [:create, :update]
  before_action :set_event, only: [:show]

  def index
    Event.current_user = current_user
    events = if params.key?('enabled')
               Event.all.where(enabled: params[:enabled] == 'true')
             else
               Event.all
             end
    render_from events
  end

  def show
    Event.current_user = current_user
    render_from @event
  end

  def create
    @event = Event.new(event_params)
    @event.image = @picture
    save_render! @event
    create_event_progress if @event.valid?
  end

  private

  def set_event
    @event = Event.find_by(event_token: params[:event_token])
    render_from message: 'Event does not exists', status: :not_found unless @event
  end

  def event_params
    params.permit(:title, :start_date, :end_date,
                  :description, :number, :coins,
                  :xp, :kind, :image)
  end

  def create_event_progress
    @event.users << User.all
  end
end
