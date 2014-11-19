# coding: utf-8
require 'yaml'
require_relative 'board'
require_relative 'cursor'

class Game

  attr_reader :board, :cursor

  def initialize
    @board = Board.new
    @cursor = Cursor.new
    @turn = :white
    @picking = true
  end

  def run
    until board.checkmate?(self.current_player)
      board.render(cursor.coordinates)
      handle_input(get_char)
    end

    display_endgame
  end

  def current_player
    @turn
  end

  private

  def picking?
    @picking
  end

  def next_turn
    @turn = @turn == :white ? :black : :white
  end

  def display_endgame
    board.render([-1, -1]) # Moves cursor offscreen
    next_turn
    puts "Checkmate!"
    puts "#{self.current_player.to_s.capitalize} wins!!!"
  end

  def handle_input(char)
    case char.downcase
    when 'w'
      cursor.up
    when 'a'
      cursor.left
    when 's'
      cursor.down
    when 'd'
      cursor.right
    when "\r"
      click
    when 'q'
      save
      exit
    when 'l'
      load
    end
  end

  def clear_screen
    system('clear')
  end

  def get_char
    begin
      system("stty raw -echo")
      str = STDIN.getc
    ensure
      system("stty -raw echo")
    end
  end

  def click
    coords = cursor.coordinates

    if picking? && board.valid_piece_selection?(coords, current_player)
      board.touch_piece_at(coords)
      @picking = false
    else
      piece_dropped = board.place_at(coords)
      if piece_dropped
        @picking = true
        next_turn
      end
    end

  end

  def save
    File.write('.chess_save', self.to_yaml)
  end

  def load
    YAML.load(File.read('.chess_save')).run
  end

end

if __FILE__ == $PROGRAM_NAME
  Game.new.run
end