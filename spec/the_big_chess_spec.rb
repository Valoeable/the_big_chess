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

    describe '#parse_position' do
        it 'returns the correct coordinates for a given position' do
            expect(game.parse_position('a1')).to eq([7][0])
            expect(game.parse_position('e4')).to eq([4][4])
            expect(game.parse_position('h8')).to eq([0][7])
        end
    end

    describe '#save_game' do
        it 'saves the game data to a file' do
            game.save_file
            expect(File.exist?('chess_game_save.txt')).to be_true
        end
    end

    describe '#load_game' do
        context 'when a saved game exists' do
            it 'loads the game data from the file' do
                game.load_file
                expect(game.current_player).to eq(:black)
                expect(game.game_over).to be_false
                expect(game.winner).to be_nil
            end
        end

        context 'when a saved game does not exist' do
            it 'prints error message' do
                allow(File).to receive(:exist?).and_return(false)
                expect{ game.load_game }.to output("No saved game found \n").to_stdout
            end
        end
    end
end