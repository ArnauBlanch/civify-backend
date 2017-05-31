class AchievementsController < ApplicationController
  def create
    @achievement = Achievement.new(achievement_params)
    if @achievement.save
      render json: @achievement, status: :created
    else
      render json: { message: 'Achievement not created' }
    end
  end

  private

  def achievement_params
    params.permit(:title, :description, :number, :kind, :coins, :xp)
  end
end
