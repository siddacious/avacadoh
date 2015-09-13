class Match < ActiveRecord::Base
  belongs_to :p1, class_name: Player, foreign_key:  'p1_id'
  belongs_to :p2, class_name: Player, foreign_key: 'p2_id'
  belongs_to :winner, class_name: Player, foreign_key: 'winner_id'

  validates :p1_army_points, :p2_army_points, :p1_control_points, :p2_control_points, :p1_list_played, :p2_list_played, :winner_id, presence: true
  # attr_accessible :round, :tournament_id, :sheet_id, :opponent_id, :list_played, :won, :control_points, :army_points

  def self.though_round(round)
    where('round < ? OR round = ?', round, round)
  end
  
  def self.generate_matches

    player_ids = Player.active.shuffle

    until player_ids.length < 2 do
      ids = player_ids.pop(2)
      match = Match.new(p1_id: ids[0], p2_id: ids[1])
      match.save(validate: false)
    end

    if player_ids.length == 1
      # fill out all match values
      last_player_id = player_ids.pop
      bye_match =  Match.create(p1_id: last_player_id,
                             p2_id: -1, p1_control_points: 3,
                             p2_control_points: 0,
                             p1_army_points: 25,
                             p2_army_points: 0,
                             p1_list_played: 1,
                             p2_list_played: 1,
                             winner_id: last_player_id)
      bye_match.save(validate: false)
    end
  end

  def self.generate_round
    point_groups = Player.active.group_by {|pl| pl.points}.to_a.sort{|a,b| b[0]<=>a[0]}

    flat_list = point_groups.collect {|points, players| players.shuffle}.flatten
    match_pairs = self.pair_groups(point_groups)
    group_pairs.each do |p1, p2|
      match = Match.new(p1: p1, p2: p2)
      match.save(valivate: false)
    end
  end

  def self.pair_groups(group_pairs_master, pair_down=nil)
    paired_groups = nil
    group_pairs = group_pairs_master.dup # do we really need to dup?

    current_group = group_pairs.shift
    remaining_groups = group_pairs

    # end condition! this must always return something
    if current_group.nil? # because [].shift == nil
      # we've been passed and empty group
      if pair_down.nil?
        return []
      else
        return [[pair_down, nil]]
      end
    end
    current_group << pair_down if pair_down
    group_permutations = current_group.permutation

    # we this group will need to pair down..
    # doing this first (and not with the "played?" culling means potentially looping through permutations we will never need)
    if current_group.length.odd?
      # remove permutations where the pair_down isn't elegible
      group_permutations =group_permutations.reject { |pr| pr.last == pair_down } if pair_down
      group_permutations = group_permutations.reject { |pr| Player.paired_down(pr.last) }
    end

    group_permutations.each do |group_permutation_master|
      group_list = group_permutation_master.dup
      match_pairs = []

      until match_pairs.length < 2
        pair = match_pair.pop(2)
        match_pairs << [pair[0], pair[1]]
      end
      new_pair_down =  match_pairs.pop if match_pairs.length == 1

      next if match_pairs.any? {|p1, p2| p1.has_played?(p2)}

      remaining_pairs = Match.pair_groups(remaining_groups, new_pair_down)

      if remaining_pairs.nil?
        next
      else
        paired_groups = match_pairs + remaining_pairs
      end

    end

    return paired_groups
  end

end