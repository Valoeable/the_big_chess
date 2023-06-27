require 'yaml'

class ChessGame
    attr_accessor :board, :current_player, :game_over, :winner, :draw

    def initialize 
        @board = setup_board
        @current_player = :white
        @game_over = false
        @winner = nil
        @draw = false
    end

    def play 
        until game_over
            display_board
            move = get_move
            break if move == "quit"
            save_game if move == "save"
            load_game if move == "load"

            if valid_move?(move)
                make_move(move)
                check_game_status
            else
                puts "Invalid move. Try again."
            end
        end

        display_board
        display_result
    end

    def setup_board

        board = Array.new(8) { Array.new(8, nil) }


        board[0][0] = "♖"
        board[0][1] = "♘"
        board[0][2] = "♗"
        board[0][3] = "♕"
        board[0][4] = "♔"
        board[0][5] = "♗"
        board[0][6] = "♘"
        board[0][7] = "♖"
        8.times{ |i| board[1][i] = "♙" }

        board[7][0] = "♜"
        board[7][1] = "♞"
        board[7][2] = "♝"
        board[7][3] = "♛"
        board[7][4] = "♚"
        board[7][5] = "♝"
        board[7][6] = "♞"
        board[7][7] = "♜"
        8.times{ |i| board[6][i] = "♟" }

        board
    end

    def display_board
        puts "\n   a b c d e f g h"
        puts "  -----------------"
        @board.each_with_index do |row, index|
            print "#{8 - index}"
            row.each { |piece| print_piece(piece) }
            puts "| #{8 - index}"
        end
        puts "  -----------------"
        puts "   a b c d e f g h\n"
    end

    def print_piece(piece)
        print piece.nil? ? "  " : " #{piece}"
    end

    def get_move
        print "#{current_player.capitalize}'s move (e.g., 'e2, e4, 'quit'): "
        gets.chomp.downcase
    end

    def make_move(move)
        from, to = move.split(" ")
        x1, y1 = parse_position(from)
        x2, y2 = parse_position(to)

        @board[x2][y2] = @board[x1][y1]
        @board[x1][y1] = nil
    end

    def valid_move?(move)
        return false unless move.match?(/^[a-h][1-8] [a-h][1-8]$/)

        from, to = move.split(" ")
        x1, y1 = parse_position(from)
        x2, y2 = parse_position(to)

        return false if @board[x1][y1].nil?
        return false unless valid_piece_move?(x1, y1, x2, y2)
        return false if own_piece_on_target?(x1, y1, x2, y2)

        true
    end

    def valid_piece_move?(x1, y1, x2, y2)
        piece = @board[x1][y1]

        case piece.downcase
        when "♙", "♟" then valid_pawn_move?(x1, y1, x2, y2)
        when "♖", "♜" then valid_rook_move?(x1, y1, x2, y2)
        when "♘", "♞" then valid_knight_move?(x1, y1, x2, y2)
        when "♗", "♝" then valid_bishop_move?(x1, y1, x2, y2)
        when "♕", "♛" then valid_queen_move?(x1, y1, x2, y2)
        when "♔", "♚" then valid_king_move?(x1, y1, x2, y2)
        else false
        end
    end

    def valid_pawn_move?(x1, y1, x2, y2)
        piece = @board[x1][y1]

        return true if piece == "♙" && x2 == x1 - 1 && y2 == y1 && @board[x2][y2].nil?
        return true if piece == "♟" && x2 == x1 + 1 && y2 == y1 && @board[x2][y2].nil?
        return true if piece == "♙" && x2 == x1 - 1 && (y2 == y1 - 1 || y2 == y1 + 1) && enemy_piece_on_target?(x1, y1, x2, y2)
        return true if piece == "♟" && x2 == x1 + 1 && (y2 == y1 - 1 || y2 == y1 + 1) && enemy_piece_on_target?(x1, y1, x2, y2) 
            
        false
    end

    def valid_rook_move?(x1, y1, x2, y2)
        return true if x1 == x2 && y1 != y2 && clear_path?(x1, y1, x2, y2, :horizontal)
        return true if y1 == y2 && x1 != x2 && clear_path?(x1, y1, x2, y2, :vertical)
        
        false
    end

    def valid_knight_move?(x1, y1, x2, y2)
        dx = (x1 - x2).abs
        dy = (y1 - y2).abs

        return true if dx == 2 && dy == 1
        return true if dx == 1 && dy == 2

        false
    end

    def valid_bishop_move?(x1, y1, x2, y2)
        return true if (x1 - x2).abs == (y1 - y2).abs && clear_path?(x1, y1, x2, y2, :diagonal)

        false
    end

    def valid_queen_move?(x1, y1, x2, y2)
            return valid_rook_move?(x1, y1, x2, y2) || valid_bishop_move?(x1, y1, x2, y2)
    end

    def valid_king_move?(x1, y1, x2, y2)
        dx = (x1 - x2).abs
        dy = (y1 - y2).abs
        
        return true if dx <= 1 && dy <= 1

        false
    end

    def clear_path?(x1, y1, x2, y2, direction)
        dx = (x2 - x1).sign
        dy = (y2 - y1).sign

        case direction 
        when :horizontal
            (y1 + dy).step(y2 - dy, dy).each { |y| return false unless @board[x1][y].nil? }
        when :vertical
            (x1 + dx).step(x2 - dx, dx).each { |x| return false unless @board[x][y1].nil? }
        when :diagonal
            (x2 + dx).step(x2 - dx, dx).zip((y1 + dy).step(y2 - dy, dy)).each { |x, y| return false unless @board[x][y].nil? }
        end

        true
    end

    def own_piece_on_target?(x1, y1, x2, y2)
        piece = @board[x1][y1]
        target_piece = @board[x2][y2]

        return false if target_piece.nil?
        return piece.downcase == target_piece.downcase
    end

    def enemy_piece_on_target?(x1, y1, x2, y2)
        piece = @board[x1][y1]
        target_piece = @board[x2][y2]

        return false if target_piece.nil?
        return piece.downcase != target_piece.downcase
    end

    def parse_position(position)
        column, row = position.split('')
        x = 8 - row.to_i
        y = column.ord - 'a'.ord
        [x, y]
    end

    def check_game_status
        if checkmate?
            @game_over = true
            @winner = current_player
        elsif stalemate?
            @game_over = true
            @draw = true
        else
            switch_players
        end
    end

    def checkmate?
        king_position = find_king_position(current_player)

        return false unless king_in_check?(king_position)

        return false if any_valid_move?(current_player)

        true
    end

    def stalemate?
        king_position = find_king_position(current_player)

        return false if king_in_check?(king_position)

        return false if any_valid_move?(current_player)

        true
    end

    def king_in_check?(king_position)
        opponent = (current_player == :white) ? :black : :white
        opponent_moves = []

        each_piece(opponent) do |piece, x, y|
            opponent_moves.concat(valid_moves_for_piece(x, y))
        end

        opponent_moves.include?(king_position)
    end

    def any_valid_move?(player)
        each_piece(player) do |piece, x, y|
            return true if valid_moves_for_piece(x, y).any?
        end

        false
    end

    def each_piece(player)
        @board.each_with_index do |row, x|
            row.each_with_index do |piece, y|
                next if piece.nil?
                next unless piece.downcase == piece_for_player(player)

                yield(piece, x, y)
            end
        end
    end

    def valid_moves_for_piece(x, y)
        piece = @board[x][y]
        valid_moves = []

        8.times do |i|
            8.times do |j|
                move = "#{x}#{y} #{i}#{j}}"
                valid_moves << move if valid_move?(move)
            end
        end

        valid_moves
    end

    def find_king_position(player)
        king = player == :white ? "♔" : "♚"

        @board.each_with_index do |row, x|
            row.each_with_index do |piece, y|
                return [x, y] if piece == king
            end
        end
    end

    def piece_for_player(player)
        player == :white ? "♔" : "♚"
    end

    def switch_players
        @current_player = @current_player == :white ? :black : :white
    end

    def display_result
        if draw
            puts 'The game ended in a draw.'
        else
            puts "#{winner.capitalize} wins the game!"
        end
    end

    def save_game
        game_data = {
            board: @board,
            current_player: @current_player
            game_over: @game_over
            winner: @winner
            draw: @draw
        }

        File.open("chess_game_save.txt", "w") do |file|
            file.write(game_data.to_yaml)
        end

        puts "Game saved."
    rescue StandardError => e
        puts "Failed to save the game #{e.message}"
    end

    def load_game
        if File.exist?("chess_game_save.txt")
            game_data = YAML.load_file("chess_game_save.txt")

            @board = game.data[:board]
            @current_player = game.data[:current_player]
            @game_over = game.data[:game_over]
            @winner = game.data[winner]
            @draw = game.data[draw]

            puts "Game loaded."
        else
            puts "No saved game found."
        end
    rescue StandardError => e
        puts "Failed to save the game #{e.message}"
    end
end

game = ChessGame.new
game.play