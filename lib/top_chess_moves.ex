defmodule TopChessMoves do
	@moduledoc """
		Posts boards to twitter
	"""

	@doc """
		Runs the twitter bot
	"""
	def run_bot do
		IO.puts "Posting board"
		spawn fn -> post_board end
		:timer.hours(1)
		|> :timer.sleep
		run_bot
	end

	@doc """
		Generate and posts a top chess move
	"""
	def post_board do
		ExTwitter.configure
		Board.random_board |> ChessEngine.randomBoards(:rand.uniform(10) + 2)
		try do
			ExTwitter.update_with_media(MoveName.name, File.read!("animation.gif"))
			time = DateTime.utc_now
			IO.puts("Posted board at #{time.hour}:#{time.minute} UTC, #{time.month}/#{time.day}")
		rescue
			_ ->
				IO.puts "Encountered an error. Waiting 30 seconds and trying again"
				:timer.seconds(30) |> :timer.sleep
				post_board
		end
	end
end

defmodule ChessEngine do
	@moduledoc """
		Generates boards, selects pieces to move, moves them.
	"""

	@doc """
		Given a board and a color, moves one of those pieces
	"""
	def moveRandomPiece(board, color) do
		selected_piece = Enum.filter(board, fn(x) -> x.color == color end)
		|> Enum.random()
		# Whaaaaaaaat if there are no pieces for a given color? Then it should stop I guess.
		# Cause one team has won, right?
		# Currently it will crash, which is good enough for government work

		possible_moves = ChessMove.fullMove(selected_piece, board)
		if Enum.empty?(possible_moves) do
			moveRandomPiece(board, color)
		else
			{x, y} = Enum.random(possible_moves)
			Board.move_piece(board, selected_piece, x, y)
		end		
	end

	@doc """
		Takes a board through a random series of moves, produces a gif of those moves at the end of it
	"""
	def randomBoards(board, times) do
		randomBoards(board, :W, times+1, [])
	end

	def randomBoards(_, _, 0, files) do
		IO.puts "------------------------"
		Draw.draw_gif(files)
	end

	def randomBoards(board, color, times, files) do
		IO.puts "------------------------"
		Draw.draw_board(board, "board_#{times}")
		if color == :W do
			randomBoards(moveRandomPiece(board, :B), :B, times - 1, files ++ ["board_#{times}.png"])
		else
			randomBoards(moveRandomPiece(board, :W), :W, times - 1, files ++ ["board_#{times}.png"])
		end
	end
end

defmodule ChessMove do
	@moduledoc """
		Determines all possible moves a given chess piece has
	"""

	@doc """
		Returns all possible moves for a given board
	"""
	def fullMove(piece, board) do
		moves = Piece.get_moves(piece)
		|> Enum.map(fn x -> collision_check(x, piece, board) end) 
		|> List.flatten
		if piece.type == :P do
			pawn_capture(piece, board, moves)
		else
			moves
		end
	end

	@doc """
		Checks if a given set of moves collides with any pieces on the board
	"""
	def collision_check(moves, color, board) do
		collision_check(moves, color, board, [])
	end

	def collision_check([], _, _, acc) do
		acc
	end

	def collision_check([{x, y} = head | tail], piece, board, acc) do
		piece_at = Board.get_piece(board, x, y)
		if piece_at == nil do
			collision_check(tail, piece, board, acc ++ [head])
		else
			if piece_at.color == piece.color do
				acc
			else
				if piece.type != :P do
					acc ++ [head]
				else
					acc
				end
			end
		end
	end

	@doc """
		Adds any possible pawn captures to the move list.
	"""
	def pawn_capture(piece, board, acc) do
		[{_, dy}] = piece.direction
		acc ++ check_pawn_capture(piece, board, {piece.x-1, piece.y + dy}) ++ check_pawn_capture(piece, board, {piece.x+1, piece.y + dy}) 
	end

	@doc """
		Checks if a pawn can capture anything at a given location
	"""
	def check_pawn_capture(piece, board, {x, y}) do
		piece_at = Board.get_piece(board, x, y)
		if piece_at == nil do
			[]
		else
			if piece_at.color == piece.color do
				[]
			else
				[{x, y}]
			end
		end
	end
end
