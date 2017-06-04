class AchievementsController < ApplicationController
  include Xattachable
  before_action :needs_admin, except: [:show, :index]
  before_action -> { set_current_user(Achievement) }, only: [:show, :index]
  before_action :set_achievement, only: [:show, :update]
  before_action :fetch_picture, only: [:create, :update]

  def create
    @achievement = Achievement.new(achievement_params)
    save_render! @achievement
    create_achievement_progresses
  end

  def index
    achievements = if params.key?('enabled')
                     Achievement.where(enabled: params[:enabled])
                   else
                     Achievement.all
                   end
    render_from achievements
  end

  def show
    render_from @achievement
  end

  def update
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

  def create_achievement_progresses
    User.all.each do |user|
      user.achievements_in_progress << @achievement
    end
  end
end
