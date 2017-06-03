class ClaimController < ApplicationController
  before_action :set_achievement
  before_action :needs_normal_user

  def create
    unless @achievement.nil?
      ap = current_user.achievement_progresses
                       .find_by(achievement_id: @achievement.id)
      if ap.completed && !ap.claimed
        ap.update(claimed: true)
        render_from(object: { coins: @achievement.coins, xp: @achievement.xp })
      elsif ap.claimed
        render_from(message: 'You have already claimed this achievement',
                    status: :bad_request)
      else
        render_from(message: 'You haven\'t completed this achievement yet',
                    status: :bad_request)
      end
    end
  end

  private

  def set_achievement
    @achievement = Achievement.find_by(achievement_token:
                                           params[:achievement_token])
    if @achievement.nil?
      render_from(message: 'Achievement does not exist', status: :not_found)
    end
  end
end
