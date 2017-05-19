module RewardsConstants
  class COINS
    ISSUE_CREATION = 1
  end
  class XP
    ISSUE_CREATION = 200

    def self.exchange_reward(price)
      100 * price
    end
  end
end