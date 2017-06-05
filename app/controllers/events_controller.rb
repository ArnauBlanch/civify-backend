class EventsController < ApplicationController
  include Xattachable
  before_action :needs_admin, except: [:show, :index]
  before_action -> { set_current_user(Event) }, only: [:show, :index]
  before_action :fetch_picture, only: [:create, :update]
  before_action :set_event, only: [:show, :update]

  def create
    @event = Event.new(event_params)
    @event.image = @picture
    @event.badge = create_badge if params[:badge]
    save_render! @event
    create_event_progress
  end

  def index
    render_from enabled_from_param(params[:enabled])
  end

  def show
    render_from @event
  end

  def update
    @event.badge = create_badge if params[:badge]
    update_render! @event, event_params
  end

  private

  def set_event
    @event = Event.find_by(event_token: params[:event_token])
    render_from message: 'Event does not exists', status: :not_found unless @event
  end

  def event_params
    params.permit(:title, :start_date, :end_date, :description, :number, :coins, :xp, :kind, :image, :badge)
  end

  def create_badge
    fetch_picture params[:badge]
    b = Badge.new(title: params[:badge][:title])
    b.icon = @picture
    b.save!
    b
  end

  def create_event_progress
    User.all.each do |user|
      user.events_in_progress << @event
    end
  end

  def enabled_from_param(enabled)
    enabled.nil? ? Event.all : Event.enabled(enabled == 'true')
  end

end
