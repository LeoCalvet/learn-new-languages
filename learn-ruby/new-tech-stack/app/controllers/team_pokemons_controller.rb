class TeamPokemonsController < ApplicationController
  def index
    @team_pokemons = TeamPokemon.all
  end

  def create
    @team_pokemon = TeamPokemon.new(team_pokemon_params)

    if @team_pokemon.save
      redirect_to team_pokemons_path, notice: "#{@team_pokemon.pokemon_name.capitalize} foi adicionado ao time", status: :see_other
    else
      redirect_back fallback_location: root_path, alert: @team_pokemon.errors.full_messages, status: :see_other
    end
  end

  def update
    @team_pokemon = TeamPokemon.find(params[:id])

    if @team_pokemon.update(nickname_params)
      redirect_to team_pokemons_path, notice: "Apelido atualizado com sucesso!", status: :see_other
    else
      redirect_to team_pokemons_path, alert: "Erro ao atualizar apelido.", status: :see_other
    end
  end

  def destroy
    @team_pokemon = TeamPokemon.find(params[:id])
    @team_pokemon.destroy

    redirect_to team_pokemons_path, notice: "#{@team_pokemon.pokemon_name.capitalize} foi removido do time.", status: :see_other
  end

  private

  def team_pokemon_params
    params.require(:team_pokemon).permit(:pokemon_id, :pokemon_name, :image_url, :nickname)
  end

  def nickname_params
    params.require(:team_pokemon).permit(:nickname)
  end
end
