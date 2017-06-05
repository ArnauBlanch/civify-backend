class AchievementsController < ApplicationController
  include Xattachable
  before_action :needs_admin, except: [:show, :index]
  before_action -> { set_current_user(Achievement) }, only: [:show, :index]
  before_action :set_achievement, only: [:show, :update]

  def create
    @achievement = Achievement.new(achievement_params)
    @achievement.badge = create_badge if params[:badge]
    save_render! @achievement
    create_achievement_progresses
  end

  def index
    render_from enabled_from_param(params[:enabled])
  end

  def show
    render_from @achievement
  end

  def update
    @achievement.badge = create_badge if params[:badge]
    update_render! @achievement, achievement_params
  end

  private

  def set_achievement
    @achievement = Achievement.find_by(achievement_token: params[:achievement_token])
    render_from message: 'Achievement does not exists', status: :not_found unless @achievement
  end

  def achievement_params
    params.permit(:title, :description, :number, :kind, :coins, :xp, :enabled, :badge)
  end

  def create_badge
    fetch_picture params[:badge]
    b = Badge.new(title: params[:badge][:title])
    b.icon = @picture
    b.save!
    b
  end

  def create_achievement_progresses
    User.all.each do |user|
      user.achievements_in_progress << @achievement
    end
  end

  def enabled_from_param(enabled)
    enabled.nil? ? Achievement.all : Achievement.enabled(enabled == 'true')
  end
end
