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
end