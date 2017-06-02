class AchievementsController < ApplicationController
  before_action :needs_admin, except: [:show, :index]

  def create
    save_render(Achievement.new(achievement_params), :created)
  end

  private

  def achievement_params
    params.permit(:title, :description, :number, :kind, :coins, :xp)
  end
end
