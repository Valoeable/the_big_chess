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
end