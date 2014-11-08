require_relative '../app/game_state.rb'

describe GameState do
  subject(:state) { GameState.create_from_grid(grid, num_mines) }

  context 'given a 5x4 grid' do
    let(:num_mines) { 0 }
    let(:grid) do
      <<-GRID
        ? ? ? ? ?
        ? ? ? ? ?
        ? ? ? ? ?
        ? ? ? ? ?
      GRID
    end

    describe '.width' do
      it 'returns 5' do
        expect(state.width).to eq(5)
      end
    end

    describe '.height' do
      it 'returns 4' do
        expect(state.height).to eq(4)
      end
    end

    describe '.index_from_point' do
      it 'returns 15 when given (0, 0)' do
        expect(state.index_from_point(0, 0)).to eq(15)
      end

      it 'returns 0 when given (0, 3)' do
        expect(state.index_from_point(0, 3)).to eq(0)
      end

      it 'returns 2 when given (2, 3)' do
        expect(state.index_from_point(2, 3)).to eq(2)
      end

      it 'returns 9 when given (4, 2)' do
        expect(state.index_from_point(4, 2)).to eq(9)
      end
    end

    describe '.point_from_index' do
      it 'returns (0, 0) when given 15' do
        expect(state.point_from_index(15)).to eq([0, 0])
      end

      it 'returns (0, 3) when given 0' do
        expect(state.point_from_index(0)).to eq([0, 3])
      end

      it 'returns (2, 3) when given 2' do
        expect(state.point_from_index(2)).to eq([2, 3])
      end

      it 'returns (4, 2) when given 9' do
        expect(state.point_from_index(9)).to eq([4, 2])
      end
    end
  end

  describe '.cell' do
    let(:num_mines) { 2 }
    let(:grid) do
      <<-GRID
        ? 2 ?
        ⚑ ? 1
        ? ? ?
      GRID
    end

    it 'returns a GameState::Cell object with a valid point' do
      expect(state.cell(0, 0)).to be_an_instance_of(GameState::Cell)
    end

    it 'raises an exception when accessing an invalid point' do
      expect{ state.cell(-1, 2) }.to raise_exception
    end

    context 'then calling Cell.state' do
      it 'returns the mine count for an explored point' do
        expect(state.cell(1, 2).state).to eq(2)
      end

      it 'returns :unknown for unexplored point' do
        expect(state.cell(1, 1).state).to eq(:unknown)
      end

      it 'returns :flagged for flagged point' do
        expect(state.cell(0, 1).state).to eq(:flagged)
      end
    end
  end

  describe '.explored_cells' do
    let(:num_mines) { 2 }
    let(:grid) do
      <<-GRID
        ? 2 ?
        ⚑ ? 1
        ? ● ?
      GRID
    end

    it 'returns all explored cells' do
      expect(state.explored_cells).to match_array([
        GameState::Cell.new(2, 1, 2),
        GameState::Cell.new(1, 2, 1),
        GameState::Cell.new(:mine, 1, 0),
      ])
    end
  end

  describe '.unexplored_cells' do
    let(:num_mines) { 2 }
    let(:grid) do
      <<-GRID
        ? 2 ?
        ⚑ ? 1
        ? ● ?
      GRID
    end

    it 'returns all unexplored cells' do
      expect(state.unexplored_cells).to match_array([
        GameState::Cell.new(:unknown, 0, 0),
        GameState::Cell.new(:flagged, 0, 1),
        GameState::Cell.new(:unknown, 0, 2),
        GameState::Cell.new(:unknown, 1, 1),
        GameState::Cell.new(:unknown, 2, 0),
        GameState::Cell.new(:unknown, 2, 2),
      ])
    end
  end

  describe '.flagged_cells' do
    let(:num_mines) { 2 }
    let(:grid) do
      <<-GRID
        ? 2 ?
        ⚑ ? 1
        ? ? ?
      GRID
    end

    it 'returns all flagged cells' do
      expect(state.flagged_cells).to match_array([
        GameState::Cell.new(:flagged, 0, 1),
      ])
    end
  end

  describe '.cells_around' do
    let(:num_mines) { 2 }
    let(:grid) do
      <<-GRID
        ? 2 ?
        ⚑ ? 1
        ? ? 1
      GRID
    end

    it 'returns the states and coordinates of nearby points' do
      expect(state.cells_around(0, 2)).to match_array([
        GameState::Cell.new(2, 1, 2),
        GameState::Cell.new(:unknown, 1, 1),
        GameState::Cell.new(:flagged, 0, 1),
      ])
    end
  end

  describe '.playing_state' do
    context 'with an explored mine' do
      let(:num_mines) { 1 }
      let(:grid) do
        <<-GRID
          ? ? ?
          ● ? ?
          ? ? ?
        GRID
      end

      it 'returns :lost' do
        expect(state.playing_state).to eq(:lost)
      end
    end

    context 'with all safe points explored' do
      let(:num_mines) { 5 }
      let(:grid) do
        <<-GRID
          2 ● ●
          3 ? ●
          2 ● 3
        GRID
      end

      it 'returns :won' do
        expect(state.playing_state).to eq(:won)
      end
    end
  end
end
