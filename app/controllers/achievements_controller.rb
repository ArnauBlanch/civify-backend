class AchievementsController < ApplicationController
  before_action :needs_admin, except: [:show, :index]
  skip_before_action :authenticate_request

  def create
    save_render(Achievement.new(achievement_params), :created)
  end

  private

  def achievement_params
    params.permit(:title, :description, :number, :kind, :coins, :xp,
                  :enabled)
  end
end
