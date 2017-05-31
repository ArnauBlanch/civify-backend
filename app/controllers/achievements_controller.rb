class AchievementsController < ApplicationController
  skip_before_action :authenticate_request

  def create
    @achievement = Achievement.new(achievement_params)
    if @achievement.save
      render json: @achievement, status: :created
    else
      render json: { message: 'Achievement not created' }
    end

  rescue ActiveRecord::RecordNotUnique
    render json: { message: 'Already exists' }, status: :bad_request
  end

  private

  def achievement_params
    params.permit(:title, :description, :number, :kind, :coins, :xp)
  end
end
