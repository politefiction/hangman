require 'json'

class Hangman
	attr_accessor :target, :hidden_word, :already_guessed, :tries

	#Word bank
	words = File.open('5desk.txt', 'r')
	@@hm_words = words.select { |line| line.length > 6 && line.length < 15 }

	def initialize
		@target = @@hm_words.sample.strip.downcase
		@tries = 6
		@already_guessed = []
		@hidden_word = []
	end

	def self.load_game?
		puts "Would you like to load your previous game?"
		answer = gets.chomp.downcase
		if answer == "y" or answer == "yes"
			self.from_json
		elsif answer == "n" or answer == "no"
			self.new.run_game
		else
			puts "Sorry, cannot recognize your response."
			self.load_game?
		end
	end

	#Conceal correct word
	def hide_word
		@target.length.times { @hidden_word.push("_") }
		puts @hidden_word.join(" ")
	end

	def run_game
		hide_word
		puts "Starting game. You can save your game at any point by entering \"save\"."
		enter_guess
		#self.instance_variables.each do |key| 
		#	puts "#{key}: #{self.instance_variable_get(key)}"
		#end
	end

	def save_game
		puts "Saving game..."
		self.to_json
		puts "Game saved."
		enter_guess
		exit
	end

	def enter_guess()
		unless @hidden_word.include? "_"
			"You've got it! The word was #{@target}!"
		else
			if @tries > 0
				puts "Please choose a letter:"
				guess = gets.chomp.downcase
				pos = 0
				save_game if guess == "save"
				check_against_target(guess, pos)
				@already_guessed.push(guess)
				puts @hidden_word.join(" ")
				enter_guess
			else
				puts "We're sorry, the correct word was #{target}!"
			end
		end
	end

	def check_against_target(guess, pos)
		if @already_guessed.include? guess
			puts "Sorry, already guessed! Please try again."
		elsif target.include? guess
			puts "Correct!"
			while pos < @target.length
				@hidden_word[pos].sub!("_", guess) if target[pos] == guess
				pos += 1
			end
		else
			@tries -= 1
			puts "Sorry, that guess is incorrect! #{@tries} tries remaining."
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

	def self.from_json()
		data = JSON.load (File.read("saved_game.json"))
		values = data.values
		save = self.new
		save.target = data['target']
		save.tries = data['tries']
		save.already_guessed = data['already_guessed']
		save.hidden_word = data['hidden_word']
		puts save.hidden_word.join (" ")
		save.enter_guess
	end

end


Hangman.load_game?




=begin
i = 0
while i < save.instance_variables.length do
	save.instance_variables[i] = values[i]
	i += 1
end



=end