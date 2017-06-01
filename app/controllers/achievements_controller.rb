class AchievementsController < ApplicationController
  skip_before_action :authenticate_request

  def create
    @achievement = Achievement.new(achievement_params)
    if @achievement.save
      render json: @achievement, status: :created
    else
      render json: { message: 'Achievement not created' }, status: :bad_request
    end
  end

  private

  def achievement_params
    params.permit(:title, :description, :number, :kind, :coins, :xp)
  end
end
