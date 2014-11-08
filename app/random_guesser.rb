require_relative './game.rb'

class RandomGuesser
  def initialize
  end

  def take_turn(state)
    while true
      x, y = rand(state.width), rand(state.height)
      return Game::Turn.new(x, y) if state.cell(x, y).state == :unknown
    end
  end
end
