require 'pokegem'
require 'json'

class PokemonInfo

	def print_pokemon(pokemonName, message)
		pokemonName.strip!

		pokemon = JSON.parse(Pokegem.get "pokemon", pokemonName.downcase )
		#Stats
		hp = pokemon["hp"]  
		attack = pokemon["attack"] 
		defense = pokemon["defense"] 
		sp_atk =  pokemon["sp_atk"]
		sp_def = pokemon["sp_def"] 
		speed = pokemon["speed"]
		word = hp.to_s + " " + attack.to_s + " " + defense.to_s + " " + sp_atk.to_s + " " + sp_def.to_s + " " + speed.to_s
		word = pokemon["name"] + ": " + word
		message.twitch word
		##Abilities
		ability = pokemon["abilities"]
		abilityWord = "Abilities:"
		ability.each{|k| abilityWord << " " << k["name"] }
		message.twitch abilityWord
		##Type
		type = pokemon["types"]
		typeWord = "Types: "
		type.each{|k| typeWord << k["name"].capitalize << " "  }
		message.twitch typeWord
	end

end
