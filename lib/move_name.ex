defmodule MoveName do
	# List of country names from https://github.com/dariusk/corpora/blob/master/data/geography/countries.json
	# with a few small edits I made
	@places ~w(Afghanistan Albania Algeria Andorra Angola Argentina Armenia Australia Austria 
		Azerbaijan Bahamas Bahrain Bangladesh Barbados Belarus Belgium Belize Benin Bhutan 
		Bolivia Botswana Brazil Brunei Bulgaria  Burundi Cambodia Cameroon Canada Chad Chile China 
		Colombia Comoros Congo Croatia Cuba Cyprus  Denmark Djibouti Dominica Ecuador Egypt Eritrea 
		Estonia Ethiopia Fiji Finland France Gabon Gambia Georgia Germany Ghana Greece Grenada 
		Guatemala Guinea Guinea-Bissau Guyana Haiti Honduras Hungary Iceland India Indonesia Iran Iraq
		 Ireland Israel Italy Jamaica Japan Jordan Kazakhstan Kenya Kiribati  Kosovo Kuwait 
		Kyrgyzstan Laos Latvia Lebanon Lesotho Liberia Libya Liechtenstein Lithuania Luxembourg 
		Macedonia Madagascar Malawi Malaysia Maldives Mali Malta  Mauritania Mauritius Mexico 
		Micronesia Moldova Monaco Mongolia Montenegro Morocco Mozambique Namibia Nauru Nepal 
		Nicaragua Niger Nigeria Norway Oman Pakistan Palau Panama  Paraguay Peru Poland Portugal 
		Qatar Romania Russia Rwanda Samoa  Senegal Serbia Seychelles  Singapore Slovakia Slovenia 
		Somalia Spain  Sudan Suriname Swaziland Sweden Switzerland Syria Taiwan Tajikistan Tanzania 
		Thailand Netherlands Philippines Togo Tonga Tunisia Turkey Turkmenistan Tuvalu Uganda Ukraine 
		UAE UK USA Uruguay Uzbekistan Vanuatu Venezuela Vietnam Yemen Zambia Zimbabwe) 
		++ ["Cape Verde", "Costa Rica", "Cote D'Ivoire", "Vatican City", "Trinidad & Tobago", 
		"Burkina Faso", "Czech Republic", "El Salvador", "Equatorial Guinea", "Dominican Republic", 
		"East Timor", "New Zealand", "Palestinian State", "North Korea", "South Korea", 
		"Papua New Guinea", "San Marino", "Sao Tome & Principe", "Saudi Arabia", "Sierra Leone", 
		"Solomon Islands", "South Africa", "South Sudan", "Sri Lanka", "St. Kitts & Nevis", 
		"St. Lucia", "St. Vincent & The Grenadines", "Marshall Islands"] #some countries are multiple words

	# List of names taken from Wikipedia's List of Chess Openings Named After People
	# https://en.wikipedia.org/wiki/List_of_chess_openings_named_after_people
	@names ~w(Abonyi Adams Adler Alapin Albin Alburt Alekhine Allgaier Anderssen Arkell Averbakh 
		Balogh Barcza Barnes Basman Becker Benko Bird Blackburne Blackmar Blumenfeld Boden Bogoljubov 
		Bogo Boleslavsky Bonsch Botvinnik Brentano Breyer Capablanca Caro Chekhover Chigorin Clemenz 
		Cochrane Colle Colman Cozio Cunningham Damiano Desprez Dory Dunst Durkin Duras Eisenberg Ellis 
		Englund Epishin Evans Fajarowicz Falkbeer Fischer Fleissig Flohr Frankenstein From Furman 
		Gajewski Glek Gligoric Gering Goglidze Grivas Grob Gunderam Gurgenidze Gusev Grenfeld Hanham 
		Hodgson Hopton Hromadka Hobner Ilyin Janowski Jasnogrodsky Jerome Kan Karklins Karpov Katalymov 
		Keene Keres Kevitz Kholmov Kieseritzky Knorre Kondratiyev Konikowski Konstantinopolsky Lamb 
		Larsen Leko Leonhardt Levenfish Levitsky Lisitsin Lolli Lucena Lundin Lutikov Makogonov 
		Marczy Marshall Max McCutcheon Mieses Mikenas Miles Moeller Monticelli Morozevich Morphy 
		Muzio Nadanian Najdorf Napoleon Nimzo Nimzowitsch Noteboom Opocensky Owen Panov Parham 
		Paulsen Petrosian Perenyi Petrov Philidor Pirc Pollock Polugaevsky Ponziani Popov Prie Puc 
		Quinteros Ragozin Roti Rice Richter Riumin Robatsch Rossolimo Rousseau Rubinstein Ruy Samisch 
		Santasiere Schallopp Schlechter Schliemann Semi Shabalov Smith Smyslov Snyder Sokolsky 
		Soldatenkov Soltis Soultanbeieff Sozin Spielmann Stamma Staunton Steinitz Sveshnikov Szen 
		Taimanov Tarrasch Tennison Torre Traxler Trompowsky Ufimtsev Uhlmann Urusov Van Velimirovic 
		Villemson Vinogradov Vitolins Wade Wagner Ware Winawer Wolf Worrall Zaitsev Zilbermints 
		Zvjaginsev Dracula)
	
	def name do
		formats = [
			fn -> "The #{person_name} #{term}" end,
			fn -> "The #{person_name}-#{person_name} #{term}" end,
			fn -> "#{person_name}'s #{term}" end,
			fn -> "The #{Enum.random(@places)} #{term}" end,
			# This is a hacky way to weigh the randomness
			fn -> "The #{person_name} #{term}" end,
			fn -> "The #{person_name}-#{person_name} #{term}" end,
			fn -> "#{person_name}'s #{term}" end,
			fn -> "The #{Enum.random(@places)} #{term}" end,
			fn -> "#{name}: #{person_name} Trap" end
		]
		Enum.random(formats).()
		
	end

	def bucket_eval(word) when is_function(word) do
		word.()
	end

	def bucket_eval(word) do
		word
	end

	def term do
		terms = ~w(Defense System Opening Gambit Game Variation Mate Attack Position) 
			++ [fn -> "Counter-#{term}" end, fn -> "Variation of #{name}" end, 
			fn -> "Defense of #{name}" end, fn -> "Attack on #{name}" end]
		new_term = Enum.random(terms)
		if is_function(new_term) do
			new_term.()
		else
			new_term
		end
	end

	# Given the number of names, we'll practically never get combination names. Which is too bad
	def person_name do
		dictionary = map_all_names(@names)
		key = Map.keys(dictionary)
		|> Enum.filter(fn x -> String.capitalize(x) == x end)
		|> Enum.random
		markov_generate(key, dictionary, key)
		# bucket_eval(Enum.random(names))
	end

	def string_split(string, size) do
		string_split(string, size, [])
	end

	def string_split("", _, acc) do
		acc ++ [""]
	end

	def string_split(string, size, acc) do
		{head, tail} = String.split_at(string, size)
		string_split(tail, size, acc ++ [head])
	end

	def markov_generate(nil, _, acc) do
		acc
	end

	def markov_generate(last_letter, dictionary, acc) do
		possible_chunks = Map.get(dictionary, last_letter)

		cond do
			# Do not end if the chunk is too short
			String.length(acc) < 3 ->
				chunk = Enum.filter(possible_chunks, fn(x) -> String.length(x) > 1 end)
				|> Enum.random
				markov_generate(String.at(chunk, 1), dictionary, acc <> chunk)
			# Try to end if the chunk is too large
			Enum.any?(possible_chunks, fn(x) -> String.length(x) < 1 end) && :rand.uniform(3) == 1 ->
				chunk = Enum.filter(possible_chunks, fn(x) -> String.length(x) < 1 end)
				|> Enum.random
				markov_generate(String.at(chunk, 1), dictionary, acc <> chunk)
			# Otherwise, just pick a chunk and go for it
			true ->
				chunk = Enum.random(possible_chunks)
				markov_generate(String.at(chunk, 1), dictionary, acc <> chunk)
		end
	end

	def map_all_names(names) do
		map_all_names(names, %{})
		# And then I'd like to remove all of the duplicate entries for key
		|> Enum.map(fn({k, v}) -> {k, Enum.uniq(v)} end)
		|> Map.new
	end

	def map_all_names([], map) do
		map
	end

	def map_all_names([head | tail], map) do
		map_all_names(tail, map_name(String.split_at(head, 1), map))
	end

	def map_name({"", ""}, map) do
		map
	end

	def map_name({head, tail}, map) do
		# current_value = Map.get(map, head, [])
		map_name(String.split_at(tail, 1), Map.update(map, head, [String.slice(tail, 0, 2)], fn x -> x ++ [String.slice(tail, 0, 2)] end))
	end
end