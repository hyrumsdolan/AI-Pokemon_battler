import sys
import openai
from config import API_KEY

openai.api_key = API_KEY

def gpt_decides(input_text):
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[
            {
                "role": "system",
                "content": "You are a Pokemon expert. You understand on a deep level how pokemon stats influence decision in game. You will receive a formatted string and will respond with which move you will do. you will be finishing the phrase [pokemonName] use [you max 5 words here]. The sting is formatted like this: YourPokemon - CurrentHP/MaxHP {atk,def,SA,SD,Sp} Move1 (PP) Move2 (PP) Move3 (PP) Move4 (PP) ** EnemyPokemon - CurrentHP/MaxHP {atk,def,SA,SD,Sp} Move1 (PP) Move2 (PP) Move3 (PP) Move4 (PP)"
            },
            {
                "role": "user",
                "content": input_text
            },
        ],
        temperature=1,
        max_tokens=256,
        top_p=1,
        frequency_penalty=0,
        presence_penalty=0
    )
    return response["choices"][0]["message"]["content"]  # Correct way to access the content

if __name__ == "__main__":
    input_data = sys.stdin.read().strip() # Read from standard input
    output_data = gpt_decides(input_data) # Call the GPT-3.5 Turbo function with the input data
    print(output_data)
