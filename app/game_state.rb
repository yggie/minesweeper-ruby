require_relative './grid.rb'

class GameState
  include Grid

  attr_reader :grid, :num_mines, :width, :height, :turns_taken

  def self.create_from_grid(grid, num_mines)
    grid_array = grid.split(/\n+/)
      .map do |row|
        row.sub(/\A\s+/, '').split(/\s+/).map do |sym|
        case sym
        when '⚑' then :flagged
        when '●' then :mine
        when /\d+/ then sym.to_i
        else :unknown
        end
      end
    end

    GameState.new(grid_array.flatten, grid_array.first.size, grid_array.size, num_mines, [])
  end

  def initialize(grid, width, height, num_mines, turns_taken)
    raise 'Invalid grid ' + grid.to_s unless grid.size == (width * height)
    @grid = grid
    @width = width
    @height = height
    @num_mines = num_mines
    @turns_taken = turns_taken
  end

  def cell(x, y)
    raise "Invalid point (#{x}, #{y})" if x < 0 || x >= @width || y < 0 || y >= height

    state = @grid[index_from_point(x, y)]
    case state
    when Numeric
      Cell.new(Integer(state), x, y)

    else
      Cell.new(state, x, y)
    end
  end

  def cells_around(x, y)
    OFFSETS.map do |offset|
      new_x = x + offset[0]
      new_y = y + offset[1]

      cell(new_x, new_y) if contains_point?(new_x, new_y)
    end.compact
  end

  def explored_cells
    @explored_cells ||= @grid.each_with_index
      .map{ |s, i| cell(*point_from_index(i)) if s.is_a?(Numeric) || s == :mine }.compact
  end

  def unexplored_cells
    @unexplored_cells ||= @grid.each_with_index
      .map{ |s, i| cell(*point_from_index(i)) unless s.is_a?(Numeric) || s == :mine }.compact
  end

  def flagged_cells
    @flagged_cells ||= @grid.each_with_index
      .map{ |s, i| cell(*point_from_index(i)) if s == :flagged }.compact
  end

  def playing_state
    @state ||=  if num_mines == (width * height - explored_cells.select{ |c| c.state != :mine }.size)
                  :won
                elsif @grid.include?(:mine)
                  :lost
                else
                  :playing
                end
  end

  class Cell
    attr_reader :state, :x, :y

    def initialize(state, x, y)
      @state = state
      @x = x
      @y = y
    end

    def ==(other)
      state == other.state && x == other.x && y == other.y
    end

    def explored?
      state.is_a?(Numeric) || state == :mine
    end

    def unexplored?
      !explored?
    end
  end
end
