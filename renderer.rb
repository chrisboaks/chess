# coding: utf-8

require_relative 'string_colors'

module Renderer

  GREEN_DOT = '•'.green

  def render(cursor_coords)

    clear_screen

    rows = []
    8.times do |row|

      cols = []
      8.times do |col|
        raw_char = (self[[row, col]] || ' ').to_s

        formatted_char = format_char(raw_char, [row, col], cursor_coords)

        cols << formatted_char
      end

      rows << ' ' * 20 + cols.join('')
    end
    puts "\n" * 5
    puts rows.join("\n")
  end

  def format_char(char, pos, cursor_coords)
    if pos == cursor_coords
      char.bg_cyan
    elsif touched_piece_moves.include?(pos)
      format_available_move(char, pos)
    elsif black_square?(pos)
      char.bg_gray
    else
      char
    end
  end

  def format_available_move(char, pos)
    if self.opponent_at?(touched_piece, pos)
      char.bg_red
    elsif black_square?(pos)
      GREEN_DOT.bg_gray
    else
      GREEN_DOT
    end
  end

  def black_square?(pos)
    pos.reduce(:+).odd?
  end

  def clear_screen
    system('clear')
  end

end
