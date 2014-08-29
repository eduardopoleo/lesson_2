require 'pry'

class Player
  attr_accessor :status
  attr_reader :name, :hand, :hand_value, :type

  def initialize(name, type)
    @name = name
    @hand = []
    @bank_total = 1000
    @type = type
    @status = nil
  end

  def draws_initial_hand(deck)
    2.times { @hand.push(deck.draw_a_card) }
  end

  def stringify_cards
    string = ''
  
    @hand.each do |hand|
      string += "#{hand[:name]} of #{hand[:suit]}"
      string += ', ' unless hand == @hand.last

    end
    string
  end
  

  def compare_both_hands

  end

  def busts?

  end

  def totals_hand_value
    @hand_value = 0
    @hand.each do |card|
      @hand_value += card[:value].to_i
    end
  end

 def blackjack_or_busted?
  if @hand_value == 21
    @status = 'gets Blackjack!'
  elsif @hand_value > 21
    @status = "went bust with a total of #{@hand_value}."
  else
    @status = "plays on with a total of #{@hand_value}."
  end
  
  puts "=> #{@name} #{@status}" 
  puts ''
end

end

class HumanPlayer < Player
  

  def shows_cards
    puts "#{@name}'s cards: #{stringify_cards}" 
  end

  def places_bet
    puts "#{@name}, you have $#{@bank_total}."
    
    loop do
      puts "Enter a number between $0 and $#{@bank_total}:"
      @bet = gets.chomp.to_i
      break if @bet > 0 && @bet <= @bank_total
    
    end
  end

  def hit_or_stand
    loop do
      puts "#{@name}, would you like to hit or stand? (Enter h or s):"
      @status = gets.chomp
      break if @status == 'h' || @status == 's'
    end
  end
  

end

class ComputerPlayer < Player
  
  def shows_cards
    puts "Dealer shows #{@hand[0][:name]} of #{@hand[0][:suit]}."
  end

  def blackjack_or_busted?
    if @hand_value == 21
      @status = 'winner'
    end
    
    puts "=> #{@name} #{@status}" 
    puts ''
  end

  def places_bet
    
  end

  def hit_or_stand

  end
end

class Deck
  def initialize
    @d = []
    card_ranks = %w(2 3 4 5 6 7 8 9 10 Jack Queen King Ace)
    card_suits = %w(hearts diamonds spades clubs)
    cards = card_ranks.product(card_suits)

    cards.each do |card|
      if /^[0-9]/ =~ card[0]
        value = card[0].to_i
      elsif /Ace/ =~ card[0]
        value = 11
      else
        value = 10
      end  

      this_card = { name: card[0], suit: card[1], value: value }

      @d.push(this_card)
    end   
    
    @d.shuffle!
  end

  def draw_a_card
    @d.pop
  end
end

class Game
  def initialize

  end

  def introduce_yourself
    system 'clear'
    puts "Welcome to Blackjack!"
    
    loop do
      puts "How many players? (Enter 1-3)"
      @number_of_players = gets.chomp
      break if /^[123]$/ =~ @number_of_players
    end

    count = 1
    @all_players = []

    @number_of_players.to_i.times do |player|
      puts "What is player #{count}'s name?"
      name = gets.chomp
      @all_players.push(HumanPlayer.new(name,'player'))
      count += 1
    end

    @all_players.push(@dealer = ComputerPlayer.new('Dealer', 'dealer'))
  end

  def play
    @deck = Deck.new

    system 'clear'
    puts "Players, place your bets!"
    @all_players.each { |player| player.places_bet }

    system 'clear'
    puts "Dealer deals..."
    puts ''
    
    @all_players.each do |player| 
      player.draws_initial_hand(@deck) 
      player.shows_cards
      player.totals_hand_value
      player.blackjack_or_busted?
    end

    @remaining_players = @all_players.select { |player| /^p.+/ =~ player.status }

    @remaining_players.each { |player| player.hit_or_stand }

    system 'clear'
    puts "Dealer deals..."
    puts ''




  end
  

 

  def try_again

  end

  


end

game = Game.new
game.introduce_yourself
game.play
