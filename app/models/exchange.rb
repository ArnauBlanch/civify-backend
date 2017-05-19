class Exchange < ApplicationRecord
  belongs_to :award
  belongs_to :user
  has_secure_token :exchange_auth_token
  validates_uniqueness_of :award_id, scope: :user_id

  def as_json(options = nil)
    super(options.merge(except: [:id, :user_id, :award_id]))
        .merge(award_hash)
  end


  def award_hash
    award_hash = JSON.parse award.to_json
    award_hash.delete "created_at"
    award_hash.delete "updated_at"
    award_hash
  end
end
