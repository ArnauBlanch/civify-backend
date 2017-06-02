class AchievementsController < ApplicationController
  before_action :needs_admin, except: [:show, :index]

  def create
    a = Achievement.new(achievement_params)
    save_render(a, :created)
    create_achievement_progresses(a) if a.valid?
  end

  def index
    achievements = Achievement.all
    achievements.each do |a|
      a.current_user = current_user
    end
    render json: achievements, status: :ok
  end

  private

  def achievement_params
    params.permit(:title, :description, :number, :kind, :coins, :xp,
                  :enabled)
  end

  def create_achievement_progresses(achievement)
    User.all.each do |user|
      if user.kind != 'admin'
        user.achievements_in_progress << achievement
      end
    end
  end
end
