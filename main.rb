require 'optparse'
require 'pry'
require_relative 'app/game.rb'
require_relative 'app/random_guesser.rb'
require_relative 'app/game_renderer.rb'

grid_string = <<-GRID
  1 1 0 0 0 0
  0 0 0 0 0 0
  0 0 0 0 0 0
  1 0 0 0 0 1
  0 0 0 0 1 0
  0 0 1 0 0 0
GRID

game = Game.create_from_grid(grid_string)
player = RandomGuesser.new
renderer = GameRenderer.new

alive = true
while alive
  sleep(0.5)
  turn = player.take_turn(game.state)
  renderer.render(state: game.state, player: player, turn: turn)
  alive = game.process_turn(turn) != :mine
end

renderer.render(state: game.state, player: player)
