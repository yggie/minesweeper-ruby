require_relative './grid.rb'
require_relative './game_state.rb'

class Game
  include Grid
  attr_reader :num_mines, :width, :height, :turns_taken

  def self.create_from_grid(grid)
    grid = grid.split(/\n+/)
      .map{ |row| row.sub(/\A\s+/, '').sub(/\s+\z/, '').split(/\s+/).map{ |v| v.to_i == 1 } }
      .select{ |row| !row.empty? }
    Game.new(grid: grid.flatten, width: grid.first.size, height: grid.size)
  end

  def initialize(grid: raise, width: raise, height: raise)
    raise 'Invalid grid ' + grid.to_s unless grid.size == (width * height)
    @mine_grid = grid
    @width = width
    @height = height
    @num_mines = grid.select{ |v| v }.size
    self.reset
  end

  def reset
    @player_grid = Array.new(@mine_grid.size, :unknown)
    @turns_taken = []
  end

  def state
    @state ||= GameState.new(@player_grid, width, height, num_mines, turns_taken)
  end

  def try_point(x, y)
    raise 'Game has ended' if state.playing_state != :playing
    index = index_from_point(x, y)
    raise "Point (#{x},#{y}) has already been explored" if @player_grid[index].is_a?(Numeric)
    unflag(x, y) if @player_grid[index] == :flagged
    @player_grid[index] = compute_state(x, y)
    expand(x, y) if @player_grid[index] == 0

    invalidate_state
    @player_grid[index]
  end

  def flag_point(x, y)
    index = index_from_point(x, y)
    raise "Point (#{x},#{y}) has already been flagged" if @player_grid[index] == :flagged
    raise "Cannot flag a known point (#{x},#{y})" unless @player_grid[index] == :unknown

    invalidate_state
    @player_grid[index] = :flagged
  end

  def unflag_point(x, y)
    index = index_from_point(x, y)
    raise "Cannot unflag (#{x},#{y}) because it isn’t flagged" unless @player_grid[index] == :flagged

    invalidate_state
    @player_grid[index] = :unknown
  end

  def compute_state(x, y)
    index = index_from_point(x, y)
    if @mine_grid[index]
      :mine
    else
      OFFSETS.inject(0) do |total, offset|
        new_x = x + offset[0]
        new_y = y + offset[1]
        if contains_point?(new_x, new_y) &&
            @mine_grid[index_from_point(new_x, new_y)]
          total + 1
        else
          total
        end
      end
    end
  end

  def process_turn(turn)
    @turns_taken << turn

    case turn.action
    when :explore then try_point(turn.x, turn.y)
    when :flag then flag_point(turn.x, turn.y)
    when :unflag then unflag_point(turn.x, turn.y)
    else raise "Unknown action: #{turn.action} for (#{turn.x},#{turn.y})"
    end
  end

  class Turn
    attr_reader :action, :x, :y

    def initialize(x, y, action = :explore)
      @action = action
      @x = x
      @y = y
    end
  end

  private

  def expand(x, y)
    invalidate_state
    OFFSETS.each do |offset|
      new_x = x + offset[0]
      new_y = y + offset[1]
      index = index_from_point(new_x, new_y)
      next if @player_grid[index] != :unknown || !contains_point?(new_x, new_y)

      @player_grid[index] = compute_state(new_x, new_y)
      expand(new_x, new_y) if @player_grid[index] == 0
    end
  end

  def invalidate_state
    @state = nil
  end
end
