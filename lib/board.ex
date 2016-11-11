defmodule Board do
	# If this was to create absurd yet plausible chess configurations, then it should have
	# some limits placed on it. In particular:
	# 	-No more than 8 pawns on each side
	#   -Pawns cannot be in the final rows
	# 	-There should be some bias towards pieces being on their own side
	def random_board do
		random_board([], :rand.uniform(20) + 4)
	end

	def random_board(board, 0) do
		# If the king is placed on top of the other king, we might not get one of each kind
		add_piece(board, Piece.new_piece(:rand.uniform(8) - 1, :rand.uniform(8) - 1, :W, :K))
		|> add_piece(Piece.new_piece(:rand.uniform(8) - 1, :rand.uniform(8) - 1, :B, :K)) 
	end

	def random_board(board, pieces) do
		add_piece(board, Piece.random_piece)
		|> random_board(pieces - 1)
	end

	def starter do
		pawns = for n <- 0..7, do: [Piece.new_piece(n, 6, :W, :P), Piece.new_piece(n, 1, :B, :P)]
		[Piece.new_piece(0, 0, :B, :R), Piece.new_piece(1, 0, :B, :N), Piece.new_piece(2, 0, :B, :B), 
		Piece.new_piece(3, 0, :B, :K), Piece.new_piece(4, 0, :B, :Q), Piece.new_piece(5, 0, :B, :B), 
		Piece.new_piece(6, 0, :B, :N), Piece.new_piece(7, 0, :B, :R),
		Piece.new_piece(0, 7, :W, :R), Piece.new_piece(1, 7, :W, :N), Piece.new_piece(2, 7, :W, :B), 
		Piece.new_piece(3, 7, :W, :K), Piece.new_piece(4, 7, :W, :Q), Piece.new_piece(5, 7, :W, :B), 
		Piece.new_piece(6, 7, :W, :N), Piece.new_piece(7, 7, :W, :R)] ++ List.flatten(pawns)
	end

	def just_pawns do
		[Piece.new_piece(1, 1, :B, :P), Piece.new_piece(2, 1, :B, :P), Piece.new_piece(3, 1, :B, :P), Piece.new_piece(4, 1, :B, :P),
		Piece.new_piece(6, 6, :W, :P), Piece.new_piece(5, 6, :W, :P), Piece.new_piece(4, 6, :W, :P), Piece.new_piece(3, 6, :W, :P)]
	end

	def add_piece(board, piece) do
		Enum.reject(board, fn(p) -> Piece.at?(piece.x, piece.y, p) end)
		|> Enum.concat([piece])
	end
	
	# Takes a given piece, removes it from the board, adds it back at the new place
	# Removes any pieces that were already at that place
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

	def get_piece(board, x, y) do
		# Returns the piece at the given location or nothing
		piece = Enum.filter(board, fn board_piece -> Piece.at?(x, y, board_piece) end)
		if piece == [] do
			nil
		else
			List.first(piece)
		end
	end
end