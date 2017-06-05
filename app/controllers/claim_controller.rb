class ClaimController < ApplicationController
  before_action :set_achievement, only: :claim_achievement
  before_action :set_event, only: :claim_event

  def claim_achievement
    ap = current_user.achievement_progresses.find_by(achievement_id: @achievement.id)
    if ap.completed && !ap.claimed
      ap.update(claimed: true)
      render_from(coins: @achievement.coins, xp: @achievement.xp)
    elsif ap.claimed
      render_from(message: 'You have already claimed this achievement', status: :bad_request)
    else
      render_from(message: 'You haven\'t completed this achievement yet', status: :bad_request)
    end
  end

  def claim_event
    ep = current_user.event_progresses.find_by(event_id: @event.id)
    if ep.completed && !ep.claimed
      ep.update(claimed: true)
      render_from(coins: @event.coins, xp: @event.xp)
    elsif ep.claimed
      render_from(message: 'You have already claimed this event', status: :bad_request)
    else
      render_from(message: 'You haven\'t completed this event yet', status: :bad_request)
    end
  end

  private

  def set_achievement
    @achievement = Achievement.find_by(achievement_token: params[:achievement_token])
    render_from(message: 'Achievement does not exist', status: :not_found) unless @achievement
  end

  def set_event
    @event = Event.find_by(event_token: params[:event_token])
    render_from(message: 'Event does not exist', status: :not_found) unless @event
  end

end
