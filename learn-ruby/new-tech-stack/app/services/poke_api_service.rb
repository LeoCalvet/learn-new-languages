class PokeApiService
  BASE_URL = "https://pokeapi.co/api/v2".freeze

  def self.fetch_list(page: 1, limit: 20)
    offset = (page.to_i - 1) * limit

    Rails.cache.fetch("pokemons_page_#{page}_limit_#{limit}", expires_in: 12.hours) do
      response = Faraday.get("#{BASE_URL}/pokemon", { limit: limit, offset: offset })
      data = JSON.parse(response.body)

      results = data["results"].map do |poke|
        id = poke["url"].split("/").last
        {
          "id" => id,
          "name" => poke["name"],
          "image_url" => "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/#{id}.png"
        }
      end

      { count: data["count"], results: results }
    end
  end

  def self.fetch_pokemon(id_or_name)
    Rails.cache.fetch("pokemon_#{id_or_name}", expires_in: 12.hours) do
      response = Faraday.get("#{BASE_URL}/pokemon/#{id_or_name.to_s.downcase}")

      return nil unless response.success?

      data = JSON.parse(response.body)
      {
        "id" => data["id"].to_s,
        "name" => data["name"],
        "image_url" => data.dig("sprites", "front_default") || ""
      }
    end
  end
end
