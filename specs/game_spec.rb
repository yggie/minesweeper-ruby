require 'pry'
require_relative '../app/game.rb'

describe Game do
  let(:grid) do
    <<-GRID
      0 0 0 0 0 0
      0 0 1 0 0 0
      0 1 0 1 0 1
      0 1 1 0 0 0
      0 0 0 0 0 0
    GRID
  end
  let(:state) { game.state }
  subject(:game) { Game.create_from_grid(grid) }

  describe '.flag_point' do
    before(:each) { game.flag_point(2, 3) }

    it 'flags a point' do
      expect(state.cell(2, 3).state).to eq(:flagged)
    end

    it 'does not count towards explored points' do
      expect(state.explored_cells.size).to eq(0)
    end
  end

  describe '.unflag_point' do
    before(:each) { game.flag_point(3, 3); game.unflag_point(3, 3) }

    it 'unflags a point' do
      expect(state.cell(3, 3).state).to eq(:unknown)
    end

    it 'does not count towards explored points' do
      expect(state.explored_cells.size).to eq(0)
    end
  end

  describe '.compute_state' do
    it 'returns the number of mines when close to mines' do
      expect(game.compute_state(1, 0)).to eq(2)
    end

    it 'returns 0 when no mines are close' do
      expect(game.compute_state(4, 0)).to eq(0)
    end

    it 'returns :mine when a mine is encountered' do
      expect(game.compute_state(5, 2)).to eq(:mine)
    end
  end

  describe '.try_point' do
    context 'when trying a point near a mine' do
      before(:each) { game.try_point(0, 1) }

      it 'returns the number of mines close to the point' do
        expect(state.cell(0, 1).state).to eq(2)
      end

      it 'reveals exactly one point' do
        expect(state.explored_cells.size).to eq(1)
      end

      context 'when no other points remain' do
        let(:grid) do
          <<-GRID
            0 1
            1 1
          GRID
        end

        it 'sets the playing state to :won' do
          expect(state.playing_state).to eq(:won)
        end

        it 'raises an exception if further moves can be made' do
          expect{ state.try_point(1, 1) }.to raise_exception
        end
      end
    end

    context 'when trying a point on a mine' do
      before(:each) { game.try_point(1, 1) }

      it 'returns the :mine state' do
        expect(state.cell(1, 1).state).to eq(:mine)
      end

      it 'reveals exactly one point' do
        expect(state.explored_cells.size).to eq(1)
      end

      it 'changes the playing state to :lost' do
        expect(state.playing_state).to eq(:lost)
      end

      it 'raises an exception if the player tries another point' do
        expect{ game.try_point(0, 0) }.to raise_exception
      end
    end

    context 'when trying a point nowhere near a mine' do
      before(:each) { game.try_point(5, 0) }

      it 'reveals all nearby points close to a mine' do
        expect(state.explored_cells).to match_array([
          GameState::Cell.new(0, 5, 0),
          GameState::Cell.new(1, 5, 1),
          GameState::Cell.new(0, 4, 0),
          GameState::Cell.new(2, 4, 1),
          GameState::Cell.new(1, 3, 0),
          GameState::Cell.new(2, 3, 1),
        ])
      end
    end
  end
end
