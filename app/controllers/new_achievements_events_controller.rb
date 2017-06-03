class NewAchievementsEventsController < ApplicationController
  def index
    if current_user.kind == 'normal'
      a = current_user.achievement_progresses.where(completed: true, claimed:
          false)
      # e = current_user.event_progresses.where(completed: true, claimed: false)
      render json: { achievements: !a.empty? }, status: :ok
    else
      render json: { message: 'Invalid request for admins and businesses' },
             status: :unauthorized
    end
  end
end
