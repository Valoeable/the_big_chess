require 'rspec'
require 'yaml'

require './lib/the_big_chess'
require_relative 'chess_game'

RSpec.describe ChessGame do
    let(:game) {ChessGame.new} 
    
    describe '#valid_move?' do
        context 'when the move is valid' do
            it 'returns true' do
                game.board[1][4] = '♙'
                expect(game.valid_move?('e2 e4')).to be_true
            end
        end

        context 'when the move is invalid' do
            it 'returns false' do
                expect(game.valid_move?('e2 e5')).to be_false
            end
        end
    end

    describe '#make_move' do
        context 'when the move is valid' do
            it 'updates the board and game state' do 
                game.make_move('e2 e4')
                expect(game.board[3][4]).to eq('♙')
                expect(game.board[1][4]).to be_nil
                expect(game.current_player).to eq(:black)
            end
        end

        context 'when the move is invalid' do
            it 'does not update the board or game state' do
                game.make_move('e2 e5')
                expect(game.board[6][4]).to be_nil
                expect(game.board[1][4]).to eq('♙')
                expect(game.current_player).to eq(:white)
            end
        end
    end

end