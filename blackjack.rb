# FIXME 1: When dealer busts, players who are still in hand should be winners
# FIXME 2: Need logic to handle natural blackjacks

require 'pry'

class Player
  attr_accessor :status, :final_status
  attr_reader :name, :hand, :hand_value, :type

  def initialize(name, type)
    @name = name
    @hand = []
    @bank_total = 1000
    @type = type
    @status = nil
  end

  def clear_data
    @hand = []
    @status = nil
    @final_status = nil
  end

  def draws_initial_hand(deck)
    2.times { @hand.push(deck.draw_a_card) }
  end

  def draws_another_card(deck)
    @hand.push(deck.draw_a_card)
  end

  def stringify_cards
    string = ''
  
    @hand.each do |hand|
      string += "#{hand[:name]} of #{hand[:suit]}"
      string += ', ' unless hand == @hand.last

    end
    string
  end

  def totals_hand_value
    @hand_value = 0
    @hand.each do |card|
      @hand_value += card[:value].to_i
    end

    if @hand_value > 21
    number_of_aces = @hand.select { |card| /Ace/ =~ card[:name] }.length
    while number_of_aces > 0
      @hand_value -= 10
      number_of_aces -= 1
      break if @hand_value <= 21 
    end
  end

  end

  def blackjack?
    if @hand_value == 21
      @status = 'blackjack'
      @final_status == 'winner'
      puts "#{@name} got blackjack!"
      puts ''
    end 
  end
end

class HumanPlayer < Player
  def shows_cards
    puts "=> #{@name}'s cards: #{stringify_cards}"
    totals_hand_value
    puts "(Current total: #{@hand_value})"
    puts '' 
  end

  def places_bet
    puts "#{@name}, you have $#{@bank_total}."
    
    if @bank_total > 0
      loop do
        puts "Enter a number between $0 and $#{@bank_total}:"
        @bet = gets.chomp.to_i
        break if @bet > 0 && @bet <= @bank_total
      end
      puts ''
    else
      puts "Sorry, you have nothing to bet with. But you can play along for fun."
      puts ''
      @bet = 0
    end
  end

   def busted?
    totals_hand_value

    if @hand_value > 21
      puts "#{@name} busted."
      puts ''
      @status = 'busted'
      @final_status = 'loser'
    end
   end

   def takes_a_turn(deck)
    if @type == 'player'
      shows_cards
      loop do
        hit_or_stand

        if @status == 'hit me'
          draws_another_card(deck)
          shows_cards
          busted? 
        end

        break if @status == 'waiting' || @status == 'busted' 
      end

      puts 'Press enter to continue...'
      gets.chomp
      system 'clear'
    end
 
  end

  def hit_or_stand
    loop do
      puts "#{@name}, would you like to hit or stand? (Enter h or s):"
      @status = gets.chomp
      break if @status == 'h' || @status == 's'
    end

    if @status == 's'
      puts "#{@name} stands."
      puts ''
      @status = 'waiting'
    else
      @status = 'hit me'
    end
  end

  def settle_up
    if @final_status == 'winner'
      @bank_total += @bet
    elsif @final_status == 'loser'
      @bank_total -= @bet
    end
  end
end

class ComputerPlayer < Player
  def shows_cards
    puts "=> Dealer is showing #{@hand[0][:name]} of #{@hand[0][:suit]}."
    puts ''
  end

  def shows_all_cards
    puts "=> #{@name}'s cards: #{stringify_cards}"
    totals_hand_value
    puts "(Current total: #{@hand_value})"
    puts '' 
  end  

  def places_bet
  end

  def hit_or_stand
  end

  def takes_a_turn(empty)
  end

  def settle_up
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
      puts ''
    end

    @all_players.push(@dealer = ComputerPlayer.new('Dealer', 'dealer'))
    @dealer = @all_players[-1]
  end

  def play
    @deck = Deck.new
    system 'clear'
    puts "Players, place your bets!"
    puts ''
    
    @all_players.each do |player| 
      # Wipe last game's data if this is a repeat appearance
      player.clear_data

      player.places_bet
    end

    system 'clear'
    
    @all_players.each do |player| 
      player.draws_initial_hand(@deck) 
      player.totals_hand_value
      player.blackjack?
    end

    if @dealer.status != 'blackjack'
      @all_players.each do |player| 
        @dealer.shows_cards
        player.takes_a_turn(@deck)
      end
    end

    if(anyone_left?)
      dealers_turn
    end

    announce_winner

    @all_players.each { |player| player.settle_up }

    try_again
  end
  
  def handle_natural_blackjacks
    puts "GOTOTOTOTOTO"


  end

  def anyone_left?
    @all_players.select { |player| player.status == 'waiting' }.length > 0
  end

  def dealers_turn
    puts "Dealer flips the hole card..."
    puts ''

    @dealer.shows_all_cards

    loop do
      @dealer.totals_hand_value

      if @dealer.hand_value < 17
        puts 'Dealer draws another card...'
        @dealer.draws_another_card(@deck)
        @dealer.shows_all_cards
      elsif @dealer.hand_value > 21
        puts 'Dealer busted!'
        @dealer.status = 'busted'
      else
        @dealer.status = 'waiting'
      end

      break if @dealer.status == 'waiting' || @dealer.status == 'busted'
    end

    puts 'Press enter to continue...'
    gets.chomp
    system 'clear'  
  end

  def announce_winner
    puts "Dealer's total: #{@dealer.hand_value}"
    puts ''

    busted_players = @all_players.select { |player| player.status == 'busted' }

    busted_players.each { |player| puts "#{player.name} busted out and lost." }
    puts ''

    @final_players = @all_players.select do |player|
      (player.status == 'waiting' || player.final_status == 'winner' || player.status == 'blackjack') && player.type != 'dealer'
    end

    if @dealer.status == 'busted'
      @final_players.each { |player| player.final_status == 'winner' }
    end

    @final_players.each do |player| 
      if player.final_status == 'winner'
        puts "#{player.name} wins! "
        break
      end

      puts "#{player.name}'s total: #{player.hand_value}"
      
      if player.hand_value > @dealer.hand_value
        puts "#{player.name} wins!"
        player.final_status = 'winner'
      elsif player.hand_value < @dealer.hand_value
        puts "#{player.name} loses."
        player.final_status = 'loser'
      else
        puts "Push! #{player.name} ties."
      end
    end
  end
 
  def try_again
    puts "Enter 'y' to play this game again:"
    response = gets.chomp

    play if response == 'y'
  end
end


game = Game.new
game.introduce_yourself
game.play
