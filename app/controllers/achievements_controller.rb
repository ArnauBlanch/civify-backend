class AchievementsController < ApplicationController
  before_action :needs_admin, only: [:create]
  before_action :set_current_user
  before_action :set_achievement, only: [:show]

  def create
    a = Achievement.new(achievement_params)
    save_render(a, :created)
    create_achievement_progresses(a) if a.valid?
  end

  def index
    render json: Achievement.all, status: :ok
  end

  def show
    render json: @achievement, status: :ok unless @achievement.nil?
  end

  private

  def achievement_params
    params.permit(:title, :description, :number, :kind, :coins, :xp,
                  :enabled)
  end

  def create_achievement_progresses(achievement)
    User.all.each do |user|
      user.achievements_in_progress << achievement if user.kind == 'normal'
    end
  end

  def set_achievement
    @achievement = Achievement.find_by(achievement_token:
                                           params[:achievement_token])
    if @achievement.nil?
      render json: { message: 'Achievement does not exist' }, status: :not_found
    end
  end

  def set_current_user
    Achievement.current_user = current_user
  end
end
