class TeamPokemon < ApplicationRecord
  validates :pokemon_id, presence: true, uniqueness: { message: "já está no time" }
  validates :pokemon_name, presence: true

  validate :team_size_limit, on: :create

  private

  def team_size_limit
    if TeamPokemon.count >= 6
      errors.add(:base, "Time já possui o máximo de 6 pokemon")
    end
  end
end
