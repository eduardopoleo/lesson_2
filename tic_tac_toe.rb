module Say
  def say(msg)
    puts "=> #{msg}"
  end
end

class Board
  def initialize
    @b = {}
    (1..9).each { |val| @b[val] = ' ' }
  end

  def draw_board
    system 'clear'
    puts " #{@b[1]} | #{@b[2]} | #{@b[3]}"
    puts "-----------"
    puts " #{@b[4]} | #{@b[5]} | #{@b[6]}"
    puts "-----------"
    puts " #{@b[7]} | #{@b[8]} | #{@b[9]}"
  end

  def empty_squares
    @b.select { |k, v| v == ' ' }.keys
  end

  def assign_square(choice)
    position = choice[0].to_i
    value = choice[1]
    @b[position] = value
  end

  def complete_winning_line
    winning_lines = [[1,2,3], [4,5,6], [7,8,9], [1,4,7], [2,5,8], [3,6,9], [1,5,9], [3,5,7]]
    winning_lines.each do |line|
      return "X" if @b.values_at(*line).count('X') == 3
      return "O" if @b.values_at(*line).count('O') == 3
    end

    nil
  end
end

class Player
  include Say
  
  attr_reader :name

  def initialize(name)
    @name = name
  end
end

class HumanPlayer < Player
  def choose_square(board)
    loop do
      say("Choose a square (1-9):")
      response = gets.chomp.to_i

      if board.empty_squares.include? response  
        return [response, 'X']
      else
        say('Please choose an empty square.')
      end
    end
  end
end

class ComputerPlayer < Player
  def choose_square(board)
    response = board.empty_squares.sample
    return [response, 'O']
  end
end

class Game
  include Say

  def introduce_yourself
    system 'clear'
    say("Let's play Tic-Tac-Toe!")
    say("What's your name?")
    response = gets.chomp
    
    @player = HumanPlayer.new(response)
    @computer = ComputerPlayer.new(nil)
  end

  def play
    @board = Board.new
    @board.draw_board
    
    loop do
      @board.assign_square(@player.choose_square(@board))
      @board.draw_board
      break if winner_exists

      @board.assign_square(@computer.choose_square(@board))
      @board.draw_board
      break if winner_exists
    end

    try_again
  end

  def winner_exists
    if @board.complete_winning_line == 'X'
      say("You won, #{@player.name}!")
      true
    elsif @board.complete_winning_line == 'O'
      say("You lost, #{@player.name}.")
      true
    else
      false
    end
  end

  def try_again
    puts ''
    say("Enter 'y' to play again. ")
    response = gets.chomp
    play if response == 'y'
  end
end

game = Game.new
game.introduce_yourself
game.play
