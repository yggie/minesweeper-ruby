module Grid
  OFFSETS = [
    [-1, -1],
    [ 0, -1],
    [ 1, -1],
    [-1,  0],
    [ 1,  0],
    [-1,  1],
    [ 0,  1],
    [ 1,  1],
  ]

  def index_from_point(x, y)
    x + (@height - y - 1) * @width
  end

  def point_from_index(index)
    return index % @width, @height - 1 - index / @width
  end

  def contains_point?(x, y)
    x >= 0 && x < @width && y >= 0 && y < @height
  end
end
