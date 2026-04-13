class PokemonsController < ApplicationController
  include Pagy::Method

  def index
    if params[:query].present?
          redirect_to pokemon_path(params[:query].downcase)
          return
    end

        page = params.fetch(:page, 1).to_i
        limit = 20

        api_response = PokeApiService.fetch_list(page: page, limit: limit)

        @pagy = Pagy::Offset.new(count: api_response[:count], page: page, items: limit)
        @pokemons = api_response[:results]
  end

  def show
    @pokemon = PokeApiService.fetch_pokemon(params[:id])

    unless @pokemon
      redirect_to pokemons_path, alert: "Pokemon não encontrado"
    end
  end
end
