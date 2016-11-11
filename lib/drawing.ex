defmodule Draw do

	@square_size 60

	# def example do
	# 	System.cmd("convert", ["board.png", "-font", "ArialUnicode", "-pointsize", "50", 
	# 		"-draw", "gravity northwest fill black text 2,0 \'♖\'", "new_board.png"], stderr_to_stdout: true)
	# end

	def draw_gif(files) do
		System.cmd("convert", ["-delay", "100", "-dispose", "previous"] 
			++ files 
			++ [List.last(files), "-loop", "0", "animation.gif"])
	end

	def draw_board(pieces, filename) do
		draw_board(pieces, filename, "gravity northwest ")
	end

	def draw_board([], filename, acc) do
		# {micro, _} = DateTime.utc_now.microsecond
		System.cmd("convert", ["board.png", "-font", "ArialUnicode", "-pointsize", "#{@square_size}", 
			"-draw", acc, "#{filename}.png"])
	end

	def draw_board([piece | tail], filename, acc) do
		draw_board(tail, filename, acc <> " fill black text #{piece.x*@square_size},#{piece.y*@square_size - 14}\'#{pieceText(piece)}\'")
	end

	defp pieceText(p) do
		cond do
			p.type == :R && p.color == :W -> "♖"
			p.type == :N && p.color == :W -> "♘"
			p.type == :B && p.color == :W -> "♗"
			p.type == :P && p.color == :W -> "♙"
			p.type == :K && p.color == :W -> "♔"
			p.type == :Q && p.color == :W -> "♕"

			p.type == :R && p.color == :B -> "♜"
			p.type == :N && p.color == :B -> "♞"
			p.type == :B && p.color == :B -> "♝"
			p.type == :P && p.color == :B -> "♟"
			p.type == :K && p.color == :B -> "♚"
			p.type == :Q && p.color == :B -> "♛"

			true -> "#{Atom.to_string(p.type)}"
		end
	end
end

defmodule DrawBoard do
	def draw(board) do
		draw(0, 0, board, "|")
	end

	def draw(x, y, _, acc) when x == 8 and y == 7, do: IO.puts acc

	def draw(x, y, board, acc) when x == 8 do
		draw(0, y + 1, board, acc <> "\n|")
	end

	def draw(x, y, board, acc) do
		piece = Enum.filter(board, fn(piece) -> Piece.at?(x, y, piece) end)
		draw(x+1, y, board, acc <> drawPiece(piece))
	end

	defp drawPiece([]), do: " |"
	defp drawPiece([p]) do
		cond do
			p.type == :R && p.color == :W -> "♖|"
			p.type == :N && p.color == :W -> "♘|"
			p.type == :B && p.color == :W -> "♗|"
			p.type == :P && p.color == :W -> "♙|"
			p.type == :K && p.color == :W -> "♔|"
			p.type == :Q && p.color == :W -> "♕|"

			p.type == :R && p.color == :B -> "♜|"
			p.type == :N && p.color == :B -> "♞|"
			p.type == :B && p.color == :B -> "♝|"
			p.type == :P && p.color == :B -> "♟|"
			p.type == :K && p.color == :B -> "♚|"
			p.type == :Q && p.color == :B -> "♛|"

			true -> "#{Atom.to_string(p.type)}|"
		end
	end

	defp drawPiece(_), do: "Draw Piece Should Receive a List With One Entry But It Didn't|"
end