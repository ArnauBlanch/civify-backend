class AchievementsController < ApplicationController
  before_action :needs_admin, only: [:create]
  before_action :set_current_user
  before_action :set_achievement, only: [:show]

  def create
    a = Achievement.new(achievement_params)
    save_render! a
    create_achievement_progresses(a) if a.valid?
  end

  def index
    render_from Achievement.all
  end

  def show
    render_from @achievement
  end

  private

  def achievement_params
    params.permit(:title, :description, :number, :kind, :coins, :xp, :enabled)
  end

  def create_achievement_progresses(achievement)
    User.all.each do |user|
      user.achievements_in_progress << achievement if user.kind == 'normal'
    end
  end

  def set_achievement
    @achievement = Achievement.find_by(achievement_token: params[:achievement_token])
    render_from message: 'Achievement does not exists', status: :not_found unless @achievement
  end

  def set_current_user
    Achievement.current_user = current_user
  end
end
