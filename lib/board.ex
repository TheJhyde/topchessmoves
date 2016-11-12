defmodule Board do
	@moduledoc """
		Provides functions related to chess boards. Boards are stored as a list of structs
	"""

	@doc """
		Generates a random board
	"""
	def random_board do
		pawns = for _ <- 0..7, do: [{:W, :P}, {:B, :P}]
		bag = [{:W, :N}, {:W, :N}, {:B, :N}, {:B, :N}, {:W, :R}, {:W, :R}, {:B, :R}, {:B, :R},
			   {:W, :B}, {:W, :B}, {:B, :B}, {:B, :B}, {:W, :Q}, {:B, :Q}] ++ List.flatten(pawns)
		random_board([], bag, :rand.uniform(20) + 4)
	end

	def random_board(board, _, 0) do
		# If the king is placed on top of the other king, we might not get one of each kind
		add_piece(board, Piece.new_piece(:rand.uniform(8) - 1, :rand.uniform(8) - 1, :W, :K))
		|> add_piece(Piece.new_piece(:rand.uniform(8) - 1, :rand.uniform(8) - 1, :B, :K)) 
	end

	def random_board(board, bag, pieces) do
		{color, type} = Enum.random(bag)
		add_piece(board, Piece.random_piece(color, type))
		|> random_board(List.delete(bag, {color, type}), pieces - 1)
	end

	@doc """
		Provides the standard opening board
	"""
	def starter do
		pawns = for n <- 0..7, do: [Piece.new_piece(n, 6, :W, :P), Piece.new_piece(n, 1, :B, :P)]
		[Piece.new_piece(0, 0, :B, :R), Piece.new_piece(1, 0, :B, :N), Piece.new_piece(2, 0, :B, :B), 
		Piece.new_piece(3, 0, :B, :K), Piece.new_piece(4, 0, :B, :Q), Piece.new_piece(5, 0, :B, :B), 
		Piece.new_piece(6, 0, :B, :N), Piece.new_piece(7, 0, :B, :R),
		Piece.new_piece(0, 7, :W, :R), Piece.new_piece(1, 7, :W, :N), Piece.new_piece(2, 7, :W, :B), 
		Piece.new_piece(3, 7, :W, :K), Piece.new_piece(4, 7, :W, :Q), Piece.new_piece(5, 7, :W, :B), 
		Piece.new_piece(6, 7, :W, :N), Piece.new_piece(7, 7, :W, :R)] ++ List.flatten(pawns)
	end

	@doc """
		Add a piece to a board. Will remove any pieces that are already at the place
	"""
	def add_piece(board, piece) do
		Enum.reject(board, fn(p) -> Piece.at?(piece.x, piece.y, p) end)
		|> Enum.concat([piece])
	end

	@doc """
		Takes a given piece, removes it from the board, adds it back at the new place
		Removes any pieces that were already at that place
	"""
	def move_piece(board, piece, x, y) do
		board = Enum.reject(board, fn(p) -> p == piece || Piece.at?(x, y, p) end)
		cond do
			piece.type == :P && piece.times == 2 -> 
				Enum.concat(board, [%{piece | x: x, y: y, times: 1}])
			piece.type == :P && piece.color == :W && y == 0 ->
				Enum.concat(board, [Piece.upgrade(piece, x, y)])
			piece.type == :P && piece.color == :B && y == 7 ->
				Enum.concat(board, [Piece.upgrade(piece, x, y)])
			true ->
				Enum.concat(board, [%{piece | x: x, y: y}])
		end
	end

	@doc """
		Returns the piece at the given x, y coordinates or nil if there's no piece there
	"""
	def get_piece(board, x, y) do
		piece = Enum.filter(board, fn board_piece -> Piece.at?(x, y, board_piece) end)
		if piece == [] do
			nil
		else
			List.first(piece)
		end
	end
end