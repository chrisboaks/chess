class Cursor
  SIZE = 8

  attr_reader :row, :col

  def initialize
    @row = 0
    @col = 0
  end

  def left
    @col = (col - 1) % SIZE
    nil
  end

  def right
    @col = (col + 1) % SIZE
    nil
  end

  def up
    @row = (row - 1) % SIZE
    nil
  end

  def down
    @row = (row + 1) % SIZE
    nil
  end

  def coordinates
    [row, col]
  end

end