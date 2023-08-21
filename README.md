# AI Pokemon Battler
This takes yling ypokestats to scrape the data from the pokemon game, then it preps it and send to ChatGPT, which will send back a choice.

Note: f anything seems stupid in the code, know that I have no idea what I'm doing

### Compatability
Need Luarocks for ChatGPT API to work. ***NOTE: I couldn't figure out how to use this, so I am using a python script for now and will revisit this in the future
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
EX: (note: the {stats} are in the order from above)
  Torchic - 24/24 {12, 12, 17, 14, 12} Scratch (33) Growl (40) Focus Energy (30) ** Wurmple - 1/14 {6, 6, 6, 6, 5} Tackle (34) String Shot (39)

This string is sent to a test.py to send it to chatGPT and then returns [PokemonName] use [Move]! that is shown in the top display

Inputs are automated and assume the cursor is hovering over "Fight"

## TODO
Minimum Expectations:
* Set up a listener for when a pokemon levels up. This will need to end Chat's input so it doesn't mess up learning moves or evolutions. It can just see if a base stat has increased.
*Set up a listener for if the enemy has died. Give User a chance to change out pokemon (Also will allow for GPT to choose own pokemon in future)
* Add detection for when battle is started (remove the need for a key press)
* Know party information and have the ability to swap out pokemon
* Beat the Elite Four
  
Quality of Life
* Give user option to allow GPT to explain why it made a move (higher token usage, but more interesting)
* Look into the ability to use items
* Shorten information string to reduce the input tokens

