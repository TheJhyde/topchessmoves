defmodule Piece do
	# defstruct x: 0, y: 0, color: :W, type: :R, direction: {0, 0}, times: 0
	defstruct [:x, :y, :color, :type, :direction, :times]

	@types [:R, :B, :N, :Q, :P]
	# @types [:P]
	@colors [:W, :B]

	def rook(x, y, color), do: %Piece{x: x, y: y, color: color, type: :R, 
		direction: rotate_directions({0, 1}), times: 8}
	def bishop(x, y, color), do: %Piece{x: x, y: y, color: color, type: :B, 
		direction: rotate_directions({1, 1}), times: 8}
	def knight(x, y, color), do: %Piece{x: x, y: y, color: color, type: :N, 
		direction: rotate_directions({1, 2}), times: 1}
	def queen(x, y, color), do: %Piece{x: x, y: y, color: color, type: :Q, 
		direction: rotate_directions({1, 1}) ++ rotate_directions({0, 1}), times: 8}
	def king(x, y, color), do: %Piece{x: x, y: y, color: color, type: :K,
		direction: rotate_directions({1, 1}) ++ rotate_directions({0, 1}), times: 1}
	# Don't even get me started on diagonal captures and en passent! Pawns are a pain! I hate them.
	def pawn(x, 6, :W), do: %Piece{x: x, y: 6, color: :W, type: :P, 
		direction: [{0, -1}], times: 2}
	def pawn(x, y, :W), do: %Piece{x: x, y: y, color: :W, type: :P, 
		direction: [{0, -1}], times: 1}
	def pawn(x, 1, :B), do: %Piece{x: x, y: 1, color: :B, type: :P, 
		direction: [{0, 1}], times: 2}
	def pawn(x, y, :B), do: %Piece{x: x, y: y, color: :B, type: :P, 
		direction: [{0, 1}], times: 1}

	def new_piece(x, y, color, :R), do: rook(x, y, color)
	def new_piece(x, y, color, :B), do: bishop(x, y, color)
	def new_piece(x, y, color, :N), do: knight(x, y, color)
	def new_piece(x, y, color, :Q), do: queen(x, y, color)
	def new_piece(x, y, color, :K), do: king(x, y, color)
	def new_piece(x, y, color, :P), do: pawn(x, y, color)

	# Random piece with not generate kings. This is the nature of things
	def random_piece do
		random_piece(Enum.random(@types))
	end

	# Pawns cannot go in the first or last rows
	def random_piece(:P) do
		new_piece(:rand.uniform(8) - 1, :rand.uniform(6), Enum.random(@colors), :P)
	end

	# Other pieces can go anywhere
	def random_piece(type) do
		new_piece(:rand.uniform(8) - 1, :rand.uniform(8) - 1, Enum.random(@colors), type)
	end

	defp rotate_directions({a, a}), do: [{a, a}, {-a, a}, {a, -a}, {-a, -a}]
	defp rotate_directions({a, 0}), do: rotate_directions({0, a})
	defp rotate_directions({0, a}), do: [{a, 0}, {-a, 0}, {0, a}, {0, -a}]
	defp rotate_directions({a, b}) do
		[{a, b}, {-a, b}, {a, -b}, {-a, -b}, {b, a}, {-b, a}, {b, -a}, {-b, -a}]
	end

	def overlap?(a, b) do
		a.x == b.x && a.y == b.y
	end

	def at?(x, y, piece) do
		piece.x == x && piece.y == y
	end

	def same_team?(a, b) do
		a.color == b.color
	end

	def get_moves(piece) do
		Enum.map(piece.direction, fn(x) -> trace_direction(x, piece.x, piece.y, piece.times) end)
		|> Enum.filter(fn x -> !Enum.empty?(x) end)
	end

	# This seems a little awkward: is this entrance function really required?
	defp trace_direction({dX, dY}, x, y, times), do: trace_direction({dX, dY}, x + dX, y + dY, times, [])

	defp trace_direction(_, _, _, 0, acc), do: acc
	defp trace_direction(_, x, _, _, acc) when x < 0 or x >= 8, do: acc
	defp trace_direction(_, _, y, _, acc) when y < 0 or y >= 8, do: acc

	defp trace_direction({dX, dY}, x, y, times, acc) do
		trace_direction({dX, dY}, x + dX, y + dY, times - 1, acc ++ [{x, y}])
	end

	def upgrade(piece, x, y) do
		%{piece | x: x, y: y, type: Enum.random([:R, :B, :N, :Q])}
	end
end