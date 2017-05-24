require 'json'

class Hangman
	attr_accessor :target, :hidden_word, :already_guessed, :tries

	# Word bank
	words = File.open('5desk.txt', 'r')
	@@hm_words = words.select { |line| line.length > 6 && line.length < 15 }

	def initialize
		@target = @@hm_words.sample.strip.downcase
		@tries = 6
		@already_guessed = []
		@hidden_word = []
	end

	# Load saved game or new game?
	def self.load_game?
		puts "Welcome to Hangman! Would you like to load your previous game?"
		answer = gets.chomp.downcase
		if answer == "y" or answer == "yes"
			puts "Loading game. You can save your game at any point by entering \"save\"."
			self.from_json
			self.play_again?
		elsif answer == "n" or answer == "no"
			self.new.run_game
		else
			puts "Sorry, unable to recognize your response."
			self.load_game?
		end
	end

	# Conceal correct word
	def hide_word
		@target.length.times { @hidden_word.push("_") }
		puts @hidden_word.join(" ")
	end

	# The game, in a nutshell
	def run_game
		puts "Starting new game. You can save your game at any point by entering \"save\"."
		hide_word
		enter_guess
		Hangman.play_again?
	end

	# Option to save game
	def save_game
		puts "Saving game..."
		self.to_json
		puts "Game saved."
	end

	# Gets player input
	def enter_guess
		unless @hidden_word.include? "_"
			puts "You've got it! The word was #{@target}!"
		else
			if @tries > 0
				puts "Incorrect guesses left: #{tries}"
				puts "Letters guessed: #{already_guessed}" unless @already_guessed.empty?
				puts "Please choose a letter:"
				guess = gets.chomp.downcase
				pos = 0
				check_against_target(guess, pos)
				@already_guessed.push(guess) unless already_guessed.include? guess or guess == "save"
				puts @hidden_word.join(" ")
				enter_guess
			else
				puts "We're sorry, the correct word was #{target}!"
			end
		end
	end

	# Compares player input to correct word (or save option)
	def check_against_target(guess, pos)
		if @already_guessed.include? guess
			puts "Sorry, already guessed! Please try again."
		elsif guess == "save"
			save_game
		elsif @target == guess
			while pos < @target.length
				@hidden_word[pos].sub!("_", guess[pos]) if target[pos] == guess[pos]
				pos += 1
			end
		elsif target.include? guess
			puts "Correct!"
			while pos < @target.length
				@hidden_word[pos].sub!("_", guess) if target[pos] == guess
				pos += 1
			end
		else
			@tries -= 1
			puts "Sorry, that guess is incorrect!"
		end
	end

	# Saving game to save file
	def to_json
		saved_game = File.open("saved_game.json", "w")
		saved_game.puts JSON.dump ({
			:target => @target,
			:tries => @tries,
			:already_guessed => @already_guessed,
			:hidden_word => @hidden_word
		})
	end

	# Loading game from save file
	def self.from_json
		data = JSON.load (File.read("saved_game.json"))
		save = self.new
		save.target = data['target']
		save.tries = data['tries']
		save.already_guessed = data['already_guessed']
		save.hidden_word = data['hidden_word']
		puts save.hidden_word.join (" ")
		save.enter_guess
	end

	# Pretty straightforward
	def self.play_again?
		puts "Would you like to play again?"
		answer = gets.chomp.downcase
		if answer == "y" or answer == "yes"
			self.new.run_game
		elsif answer == "n" or answer == "no"
			puts "Thanks for playing!"
			exit
		else
			puts "Sorry, unable to recognize your response."
			self.play_again?
		end
	end

end


Hangman.load_game?





=begin

Other possible changes:
-Refactoring/cleaning up code
-Actual Hangman
-Have game check if saved game already exists first

=end