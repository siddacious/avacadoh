class PlayerSheet < ActiveRecord::Base
  belongs_to :player, class_name: User
  has_many :results, class_name: Match, foreign_key: 'sheet_id'

  attr_accessible :player_id, :faction, :list_1, :list_2

end