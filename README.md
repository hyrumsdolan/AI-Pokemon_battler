# AI Pokemon Battler
This take yling ypokestats to scrape the data from the pokemon game, then it preps it and send to ChatGPT, which will send back a choice.

Note: I don't know what I'm doing.

### Compatability
Need Luarocks for ChatGPT API to work.
1. Download Luarocks
2. Add to System Variables Path
3. Check command prompt with 'luarocks --version' to insure it is set up

Need OpenAI Package
1. Check in command window 'pip show openai'
2. If you dont have it then use 'pip install openai'


### Basic Explanation
Tons of data is scraped, but only a few are relevant in move decisions (on the level that I care about for now)
* Current / Max HP
* Attack
* Defence
* Special Attack
* Special Defence
* Speed
* Moves and PP of each

These moves are then formatted to be short to reduce token usage (Once debugging is done, it should be even shorter)
EX: (note: the {numbers} are in the order from Important Componets)
  Torchic - 24/24 {12, 12, 17, 14, 12} Scratch (33) Growl (40) Focus Energy (30) ** Wurmple - 1/14 {6, 6, 6, 6, 5} Tackle (34) String Shot (39)

This string as of now is sent to the output console on a C key release. That output then can be copy and pasted into Chat GPT and the user can then enact GPT's decision.

## TODO
Minimum Expectations:
* Connect OpenAI API and allow for GPT-4 to output to the debug console
* Beat the Elite Four
  
Quality of Life
* Give user option to allow GPT to explain why it made a move (higher token usage, but more interesting)
* Look into the ability to use items
* Shorten information string to reduce the input tokens
* Add detection for when battle is started
* Set up commands for GPT to enact moves on it's own (note: maybe an okay command inbetween each move incase of needed intervention. Also should have GPT "hold" spacebar during it's moves to reduce chance of early input.)