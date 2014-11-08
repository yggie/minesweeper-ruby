class RiskManifold
  def initialize
  end

  def take_turn(state)
    cells = state.unexplored_cells.map do |cell|
      risk_factor = state.cells_around(cell.x, cell.y).inject(1) do |total, neighbouring_cell|
        if inner_cell.explored?
          n = state.cells_around(neighbouring_cell.x, neighbouring_cell.y)
            .select(&:unexplored?).size
          total * neighbouring_cell.state * n
        else
          total
        end
      end

      { cell: cell, risk: risk_factor }
    end.sort_by{ |rcell| rcell.fetch(:risk) }
  end

  def rebuild_risk_manifold
  end
end
