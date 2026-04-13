class CreateTeamPokemons < ActiveRecord::Migration[8.0]
  def change
    create_table :team_pokemons do |t|
      t.string :pokemon_name
      t.string :pokemon_id
      t.string :image_url
      t.string :nickname

      t.timestamps
    end
  end
end
