require_relative 'pieces'
require_relative 'renderer'

class Board

  include Renderer

  attr_reader :touched_piece, :touched_coordinates, :touched_piece_moves


  private

  attr_reader :grid, :black_king, :white_king


  public

  def initialize
    @grid = Array.new(8) { Array.new(8) }
    populate_grid
    @touched_piece_moves = []
    @black_king = find_king(:black)
    @white_king = find_king(:white)
  end

  def [](coords)
    row, col = coords
    grid[row][col]
  end

  def []=(coords, piece)
    row, col = coords
    grid[row][col] = piece
  end

  def inspect
    "A board."
  end

  def each_piece(color = nil, &prc)
    grid.flatten.compact.select do |piece|
      color.nil? || piece.color == color
    end.each(&prc)
  end

  def each_coordinate(&prc)
    8.times do |i|
      8.times do |j|
        prc.call([i, j])
      end
    end
    nil
  end

  def touch_piece_at(coordinates)
    @touched_piece = self[coordinates]
    @touched_coordinates = coordinates
    @touched_piece_moves = self.touched_piece.valid_moves(coordinates)
  end

  def place_at(coordinates)
    if touched_piece_moves.include?(coordinates)
      self[coordinates] = touched_piece
      self[touched_coordinates] = nil
      touched_piece.first_move = false
      @touched_piece_moves = []
      @touched_piece = nil
      true
    else
      false
    end
  end

  def piece_color_at(coordinates)
    piece = self[coordinates]

    return nil unless piece

    piece.color
  end

  def coordinates_of(piece)
    each_coordinate do |coordinate|
      return coordinate if self[coordinate] == piece
    end
    nil
  end

  def teammate_at?(piece, coordinates)
    anyone_at?(coordinates) && piece.same_color_as?(self[coordinates])
  end

  def opponent_at?(piece, coordinates)
    anyone_at?(coordinates) && !piece.same_color_as?(self[coordinates])
  end

  def anyone_at?(coordinates)
    coordinates.all? { |coord| coord.between?(0, 7) } &&
    !self[coordinates].nil?
  end

  def in_check?(color)
    all_moves = []

    king = (color == :white ? white_king : black_king)
    other_color = (color == :white ? :black : :white)

    each_piece(other_color) do |piece|
      all_moves << piece.moves(coordinates_of(piece))
    end

    all_moves.flatten(1).include?(coordinates_of(king))
  end

  def leaves_king_in_check?(from_pos, to_pos, player_color)
    # We need to imagine a board where the move has happened
    # and a piece may have been captured and removed
    # Then, switch back.

    temp = self[to_pos]
    self[to_pos] = self[from_pos]
    self[from_pos] = nil

    result = self.in_check?(player_color)

    self[from_pos] = self[to_pos]
    self[to_pos] = temp

    result
  end

  def checkmate?(color)
    all_moves = []
    each_piece(color) do |piece|
      all_moves << piece.valid_moves(piece.coordinates)
    end
    in_check?(color) && all_moves.flatten.empty?
  end

  def valid_piece_selection?(coords, current_player)
    piece_color_at(coords) == current_player &&
    self[coords].has_valid_moves?(coords)
  end


  private

  def populate_grid
    grid[0] = populate_royal_court(:black)
    grid[1] = populate_pawns(:black)
    grid[6] = populate_pawns(:white)
    grid[7] = populate_royal_court(:white)
  end

  def populate_royal_court(color)
    [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook].map do |piece|
      piece.new(color, self)
    end
  end

  def populate_pawns(color)
    pawns = []
    8.times do
      pawns << Pawn.new(color, self)
    end
    pawns
  end

  def find_king(color)
    self.each_piece do |piece|
      if piece.class == King && piece.color == color
        return piece
      end
    end
  end

end

