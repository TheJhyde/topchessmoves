defmodule TopChessMovesTest do
  use ExUnit.Case
  doctest TopChessMoves

  test "Check for pawn moves, no captures" do
    pawn = Piece.pawn(2, 6, :W)
    board = [pawn]
    assert ChessMove.fullMove(pawn, board) == [{2, 5}, {2, 4}]
  end

  test "Pawn moves, there's something in the way!" do
    pawn = Piece.pawn(2, 6, :W)
    knight = Piece.knight(2, 5, :W)
    board = [pawn, knight]
    assert ChessMove.fullMove(pawn, board) == []
  end

  test "Pawn moves, there's something in the way, opposite color" do
    pawn = Piece.pawn(2, 6, :W)
    knight = Piece.knight(2, 4, :B)
    board = [pawn, knight]
    assert ChessMove.fullMove(pawn, board) == [{2, 5}]
  end

  test "Check for pawn moves, one capture" do
    pawn = Piece.pawn(2, 6, :W)
    knight = Piece.knight(3, 5, :B)
    rook = Piece.knight(1, 5, :W)
    board = [pawn, knight, rook]
    assert ChessMove.fullMove(pawn, board) == [{2, 5}, {2, 4}, {3, 5}]
  end

  test "Check for pawn moves, two captures" do
    pawn = Piece.pawn(2, 6, :W)
    knight = Piece.knight(3, 5, :B)
    rook = Piece.knight(1, 5, :B)
    board = [pawn, knight, rook]
    assert ChessMove.fullMove(pawn, board) == [{2, 5}, {2, 4}, {1, 5}, {3, 5}]
  end

end
