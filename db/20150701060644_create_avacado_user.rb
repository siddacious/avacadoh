class CreateAvacadoUser < ActiveRecord::Migration
  def up
    create_table(:avacadoh_users, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.column :first_name, :string, :limit => 80
      t.column :last_name, :string, :limit => 255
      t.column :email_address, :string, :limit => 80
      t.timestamps
    end

    create_table(:avacadoh_tournaments, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.string :location
      t.datetime :date
      t.integer :point_level
      t.string :format
      t.timestamps
    end
    create_table(:avacadoh_player_sheets, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.integer :player_id
      t.string :faction
      t.text :list_1
      t.text :list_2
      t.timestamps
    end
    create_table(:avacadoh_matches, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8') do |t|
      t.integer :round
      t.integer :tournament_id
      t.integer :sheet_id
      t.integer :opponent_id
      t.integer :list_played
      t.boolean :won
      t.integer :control_points
      t.integer :army_points
      t.timestamps
    end
  end

  def down
    drop_table :avacadoh_users
    drop_table :avacadoh_tournaments
    drop_table :avacadoh_player_sheets
    drop_table :avacadoh_matches
  end
end
