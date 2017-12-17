require 'sinatra'
require 'sinatra/reloader'
require 'json'
require 'erb'

set :game, nil
enable :sessions


get '/' do
	@answer1 = params["answer1"]
	@message2 = session.delete(:message)
	settings.game ||= start_game(@answer1) if @answer1
	@answer2 = params["answer2"]
	select_image if settings.game
	play_again?(@answer2) if @answer2
	erb :index , :locals => { :game => settings.game }
end

def start_game(answer)
	if answer == "yes"
		@message1 = "Previous save loaded."
		Hangman.from_json
	else
		@message1 = "New game loaded."
		Hangman.new
	end
end

post '/' do 
	@guess = params["guess"]
	@game = settings.game
	@game.enter_guess(@guess)
	session[:message] = assign_message
	#@image = "images/hangman0.jpg"
	unless @guess == "save" or @game.already_guessed.include? @guess
		@game.already_guessed << @guess 
	end
	redirect "/?guess=#{@guess}" if @guess
end

def assign_message
	if @guess == "save"
		"Game saved."
	elsif @game.already_guessed.include? @guess
		"Sorry, already guessed! Please try again."
	else 
		if @game.target.include? @guess 
			"Correct!"
		else
			"Sorry, that guess is incorrect!"
		end
	end
end

def select_image
	files = Dir.entries("public/images").select { |file| file.include? "hangman" }
	files.sort!
	files.each_with_index do |file, ind|
		@image = "images/#{file}" if ind == settings.game.tries
	end
end

def game_over?
	if settings.game
		if (settings.game.tries == 6) or (!settings.game.hidden_word.include? "_")
			true
		else
			false
		end
	else
		false
	end
end

def play_again?(answer)
	if answer == "yes"
		@message1 = "New game loaded."
		settings.game = Hangman.new 
		select_image
	else
		@message3 = "Thanks for playing!"
	end
end

class Hangman
	attr_accessor :target, :hidden_word, :already_guessed, :tries

	words = File.open('5desk.txt', 'r')
	@@hm_words = words.select { |line| line.length > 6 && line.length < 15 }

	def initialize
		@target = @@hm_words.sample.strip.downcase
		@tries = 0
		@already_guessed = []
		@hidden_word = []
	end


	def self.load_game?
		puts "Welcome to Hangman! Would you like to load your previous game? (Y/N)"
		answer = gets.chomp.downcase
		if answer[0] == "y"
			puts "Loading game. You can save your game at any point by entering \"save\"."
			self.from_json; self.play_again?
		elsif answer[0] == "n"
			self.new.run_game
		else
			puts "Sorry, unable to recognize your response."
			self.load_game?
		end
	end

	def hide_word
		@target.length.times { @hidden_word.push("_") }
	end

	def run_game # Remove?
		puts "Starting new game. You can save your game at any point by entering \"save\"."
		hide_word
		puts; process_guess
		Hangman.play_again?
	end

	def save_game
		self.to_json
		"Game saved."
	end

	def process_guess(guess) # Remove?
		unless @hidden_word.include? "_"
			"You've got it! The word was #{@target}!"
		else
			enter_guess(guess)
		end
	end

	def choose_letter(guess)
		pos = 0
		if @already_guessed.include? guess
			"Sorry, already guessed! Please try again."
		else
			check_against_target(guess, pos)
		end
	end

	def enter_guess(guess)
		if @tries < 6
			choose_letter(guess)
		else # Do I need this?
			"Sorry, the correct word was #{@target}!"
		end
	end

	# Add all this to the html? Idk
	def check_against_target(guess, pos)
		if guess == "save"
			save_game
		elsif @target.include? guess
			update_hidden_word(guess, pos)
			#"Correct!"
		else
			@tries += 1
			#"Sorry, that guess is incorrect!"
		end
		#"You've got it! The word was #{@target}!" unless @hidden_word.include? "_"
	end

	def update_hidden_word(guess, pos)
		while pos < @target.length
			if @target == guess
				@hidden_word[pos].sub!("_", guess[pos]) if @target[pos] == guess[pos]
			else
				@hidden_word[pos].sub!("_", guess) if @target[pos] == guess
			end
			pos += 1
		end
	end


	def to_json
		saved_game = File.open("saved_game.json", "w")
		saved_game.puts JSON.dump ({
			:target => @target,
			:tries => @tries,
			:already_guessed => @already_guessed,
			:hidden_word => @hidden_word
		})
	end

	def self.from_json
		data = JSON.load (File.read("saved_game.json"))
		save = self.new
		save.target = data['target']
		save.tries = data['tries']
		save.already_guessed = data['already_guessed']
		save.hidden_word = data['hidden_word']
		save
	end

	def self.play_again? # Remove?
		puts "Would you like to play again? (Y/N)"
		answer = gets.chomp.downcase
		if answer[0] == "y"
			self.new.run_game
		elsif answer[0] == "n"
			puts "Thanks for playing!"
			exit
		else
			puts "Sorry, unable to recognize your response."
			self.play_again?
		end
	end
end



#Hangman.load_game?





=begin

		elsif @target == guess
			while pos < @target.length
				@hidden_word[pos].sub!("_", guess[pos]) if @target[pos] == guess[pos]
				pos += 1
			end
		elsif @target.include? guess
			puts "Correct!"
			while pos < @target.length
				@hidden_word[pos].sub!("_", guess) if @target[pos] == guess
				pos += 1
			end

Other possible changes:
-Refactoring/cleaning up code
-Actual Hangman
-Have game check if saved game already exists first

_________
|		|
|	   ( )
|      \|/
|		|
|		|
|      / \
|
----------


to start:
_________
|		
|	   
|      
|		
|		
|      
|
----------


=end