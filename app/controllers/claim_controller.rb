class ClaimController < ApplicationController
  before_action :set_achievement, only: :claim_achievement
  before_action :set_event, only: :claim_event

  def claim_achievement
    ap = current_user.achievement_progresses.find_by(achievement_id: @achievement.id)
    if ap.completed && !ap.claimed
      ap.update(claimed: true)
      badge = ap.achievement.badge
      current_user.badges << badge
      render_from(add_rewards: true, coins: @achievement.coins, xp: @achievement.xp, badge: badge)
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
      badge = ep.event.badge
      current_user.badges << badge
      render_from(add_rewards: true, coins: @event.coins, xp: @event.xp, badge: badge)
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
