# coding: utf-8

class Piece

  attr_reader :display_character, :deltas, :color, :board

  attr_accessor :first_move

  def initialize(color, board)
    @board = board
    @color = color
    @display_character = self.character(color)
    @first_move = true
  end

  def to_s
    @display_character
  end

  def inspect
    @display_character
  end

  def valid_moves(coords)
    moves = self.moves(coords)
    piece_coordinates = self.coordinates

    moves.reject do |move|
      board.leaves_king_in_check?(piece_coordinates, move, self.color)
    end
  end

  def has_valid_moves?(coords)
    !valid_moves(coords).flatten.empty?
  end

  def coordinates
    board.coordinates_of(self)
  end

  def same_color_as?(other_piece)
    return false unless other_piece
    self.color == other_piece.color
  end

  private

  def on_board?(coords)
    coords.all? { |num| num.between?(0, 7) }
  end

end

class SlidingPiece < Piece

  def moves(coordinates)
    x, y = coordinates

    lines = []
    self.deltas.each do |dx, dy|
      one_line = []

      7.times do |i|
        coords = [x + (i + 1) * dx, y + (i + 1) * dy]

        break if !on_board?(coords) || board.teammate_at?(self, coords)

        lines << coords

        break if board.opponent_at?(self, coords)
      end

    end

    lines
  end
end

class SteppingPiece < Piece

  def moves(coordinates)
    x, y = coordinates
    lines = []

    deltas.each do |dx, dy|
      coords = [x + dx, y + dy]

      lines << coords if on_board?(coords) && !board.teammate_at?(self, coords)
    end

    lines
  end

end

class King < SteppingPiece

  def character(color)
    color == :white ? '♔' : '♚'
  end

  def deltas
    [[1, 1], [-1, -1], [1, -1], [-1, 1],
     [1, 0], [0, 1], [-1, 0], [0, -1]]
  end
end

class Queen < SlidingPiece

  def character(color)
    color == :white ? '♕' : '♛'
  end

  def deltas
    [[1, 1], [-1, -1], [1, -1], [-1, 1],
     [1, 0], [0, 1], [-1, 0], [0, -1]]
  end
end

class Rook < SlidingPiece

  def character(color)
    color == :white ? '♖' : '♜'
  end

  def deltas
    [[1, 0], [0, 1], [-1, 0], [0, -1]]
  end
end

class Bishop < SlidingPiece

  def character(color)
    color == :white ? '♗' : '♝'
  end

  def deltas
    [[1, 1], [-1, -1], [1, -1], [-1, 1]]
  end
end

class Knight < SteppingPiece

  def character(color)
    color == :white ? '♘' : '♞'
  end

  def deltas
    [[1, 2], [1, -2], [-1, 2], [-1, -2],
     [2, 1], [2, -1], [-2, 1], [-2, -1]]
  end
end

class Pawn < Piece

  def character(color)
    color == :white ? '♙' : '♟'
  end

  def moves(coordinates)
    row, col = coordinates
    dir = (self.color == :white ? -1 : 1)
    moves = []

    # Disallow forward captures
    single_hop = [row + dir, col]
    if on_board?(single_hop) && !board.anyone_at?(single_hop)
      moves << single_hop
    end

    # Allow diagonal captures
    capture1 = [row + dir, col + dir]
    moves << capture1 if board.opponent_at?(self, capture1)

    capture2 = [row + dir, col - dir]
    moves << capture2 if board.opponent_at?(self, capture2)

    # Allow moving twice if it's the first move
    double_hop = [row + 2 * dir, col]
    moves << double_hop if self.first_move && !board.anyone_at?(double_hop)

    moves
  end
end