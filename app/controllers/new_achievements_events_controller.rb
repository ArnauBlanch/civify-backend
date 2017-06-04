class NewAchievementsEventsController < ApplicationController

  def index
    achievements = current_user.achievement_progresses.where(completed: true, claimed: false)
    events = current_user.event_progresses.where(completed: true, claimed: false)
    render_from achievements: !achievements.empty?, events: !events.empty?
  end

end
