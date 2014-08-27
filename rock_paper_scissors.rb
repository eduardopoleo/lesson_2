class Hand
  include Comparable

  attr_reader :name, :choice

  HAND_NAMES = {'r' => 'rock', 'p' => 'paper', 's' => 'scissors'}

  def initialize(name)
    @name = name
  end

  def announce_choice
    "#{name} chose #{HAND_NAMES[@choice]}."
  end

  def <=>(other_player)
    if @choice == other_player.choice
      0
    elsif (@choice == 'r' && other_player.choice == 's') || (@choice == 'p' && other_player.choice == 'r') || (@choice == 's' && other_player.choice == 'p')
      1
    else
      -1
    end
  end
end

class PlayerHand < Hand
  def chooses
    loop do
    Game::say("Choose rock, paper or scissors (r, p, or s):")
    @choice = gets.chomp
    break if @choice == 'r' || @choice == 'p' || @choice == 's'
    end

    system 'clear'
    announce_choice
  end
end

class ComputerHand < Hand
  def chooses
    @choice = HAND_NAMES.keys.sample
    announce_choice
  end
end

class Game
  def self.say(msg)
    puts "=> #{msg}"
  end
  
  def self.introduce_yourself
    system 'clear'
    say("Welcome to my Rock, Paper, Scissors Game!")
    
    say("Enter your name:")
    name = gets.chomp
    
    @player = PlayerHand.new(name)
    @computer = ComputerHand.new('Wile E. Computer')
  end

  def self.play
    system 'clear'
    say("Okay, #{@player.name}. Let's battle #{@computer.name}.")
    
    say(@player.chooses)
    say(@computer.chooses)
    compare_hands
    try_again
  end

  def self.compare_hands
    if @player == @computer
      say("It's a tie.")
    else
      say(winning_msg(@player.choice, @computer.choice))
    end

    if @player > @computer
      say("You won, #{@player.name}!")
    else
      say("You lost, #{@player.name}.")
    end
  end

  def self.winning_msg(choice_1, choice_2)
    result = [choice_1, choice_2].sort
    
    if result == ['p', 'r']
      msg = 'Paper covers rock.'
    elsif result == ['p','s']
      msg = 'Scissors cut paper.'
    else
      msg = 'Rock breaks scissors.'
    end

    msg
  end

  def self.try_again
    puts ''
    say("Enter 'y' to try again.")
    answer = gets.chomp
    
    if answer == 'y'
      play
    else
      say("Bye, #{@player.name}!")sub
    end
  end

  introduce_yourself
  play
end

rock_paper_scissors = Game.new

