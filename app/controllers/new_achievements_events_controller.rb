class NewAchievementsEventsController < ApplicationController

  def index
    achievements = current_user.achievement_progresses.unclaimed
    events = current_user.event_progresses.unclaimed
    render_from achievements: achievements, events: events
  end

end
