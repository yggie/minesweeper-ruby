require 'colorize'

class GameRenderer
  attr_accessor :cell_width

  def initialize(cell_width: 3)
    @cell_width = cell_width
  end

  def render(state: raise, player: nil, turn: nil)
    block = compute_render_block(state, player, turn)

    block.each do |row|
      puts "\t#{row}"
    end
  end

  def render_group(blocks)
    raise 'Not implemented'
  end

  private

  def compute_render_block(state, player = nil, turn = nil)
    total_width = [cell_width * state.width, player.class.name.size].max
    separator = '-' * total_width
    play_state_color = case state.playing_state
                       when :lost then :red
                       when :won then :green
                       else :white
                       end
    strings = [
      player.class.name.center(total_width).white,
      "Turn #{state.turns_taken.size}".center(total_width).white,
      state.playing_state.to_s.upcase.center(total_width).send(play_state_color),
      separator.center(total_width).white
    ]

    y = state.height
    rendered = state.grid.each_slice(state.width).map do |slice|
      y = y - 1
      x = -1
      slice.map do |char|
        x = x + 1
        if turn && turn.x == x && turn.y == y
          case turn.action
          when :flag then '█'.center(cell_width).yellow
          when :explore then '█'.center(cell_width).blue
          else raise "Unknown action: #{turn.action}"
          end
        else
          case char.to_s
          when 'flagged'
            '⚑'.center(cell_width).yellow

          when 'mine'
            '●'.center(cell_width).red

          when /\d+/
            char.to_s.center(cell_width).green

          when 'unknown'
            '?'.center(cell_width)

          else
            char.to_s.center(cell_width).cyan

          end
        end
      end.join('')
    end

    strings.concat(rendered.to_a)
    strings << separator.center(total_width).white
    strings << ''.center(total_width)
  end
end
