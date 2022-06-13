require 'pry'
require "json"

class Game
    def initialize
      @answer = nil
      @board = nil
      @remaining_guesses = nil
      @letters_used = []
      @game_details = nil
    end

  def boot_game(file)
    if File.file?("saved_hangman.json") #file exists
      puts "would you like to load your previous game: Y/N"
      load = gets.chomp.downcase
      if load == 'y'
        load_game_data(file)
      else
        new_game
      end
    else
      new_game
    end
end

  def load_game_data(file)
    file_data = File.read(file)
    file_string = JSON.parse(file_data)
    
    #set object variables
    @answer = file_string['answer']
    @board=file_string['board']
    @remaining_guesses=file_string['remaining_guesses']
    @game_details = {'answer'=> @answer, 'board'=> @board, "remaining_guesses"=> @remaining_guesses}
    
    play
  end

  def new_game
    #set object variables
    @answer = set_answer
    @board = Array.new(@answer.length){"_"}
    @remaining_guesses = 6
    @game_details = {'answer'=> @answer, 'board'=> @board, "remaining_guesses"=> @remaining_guesses}
    
    play
  end

  def delete_game
    File.delete("saved_hangman.json") if File.exist?("saved_hangman.json")
  end

  def set_answer
    words = File.open('hangman_words.txt')
    random_word = words.select{|word| word.length > 5 and word.length < 12}.sample
    answer = random_word[0..-2]
  end

  def play
    board_length = @board.length
    board_copy = @board
    display_board
    loop do
      puts "guesses left: #{@remaining_guesses}"
      puts "enter a letter"
      guess = gets.chomp
      
      check_for_letters_in_answer(guess)
      
      board_length = num_of_spaces
      
      if @board.count("_") == 0
        puts "You won!"
        delete_game
        return
      end
      
      if @remaining_guesses == 0
        puts "You lost!"
        delete_game
        return
      end

    end
  end

  def check_for_letters_in_answer(guess)
    split_answer = @answer.split("")
    if guess == "exit"
        serialize
        exit
    elsif guess.length > 1
        puts "please only enter a single letter"
        return
    elsif !split_answer.include?(guess)
        @letters_used.push(guess)
        @remaining_guesses -= 1
    else
        @letters_used.push(guess)
        split_answer.each_with_index do |letter, i|
            if guess == letter
                @board[i] = guess 
            end
        end
    end
    display_board
  end

  def display_board
    puts "#{@board.join}"
    puts "Letters used: #{@letters_used}"
  end

  def num_of_spaces
    @board.count{|space| space == "_"}
  end

  def serialize
    puts "would you like to save your game: Y/N"
    save = gets.chomp.downcase
    if save == 'y'
      saved_game = @game_details.to_json
      File.open("saved_hangman.json", "w"){|f| f.write(saved_game)}
      puts "your game has been saved"
    elsif save == 'n'
      delete_game
    else
        return
    end
  end
end

game = Game.new
game.boot_game("saved_hangman.json")


