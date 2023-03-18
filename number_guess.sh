#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

CREATE_USER() {
CREATE_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
}

FIND_USER() {
USER=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
}

PLAY_GAME() {
SECRET_NUMBER=$(( (RANDOM % 1000) + 1 ))
NUMBER_OF_GUESSES=1

echo -e "\nEnter your username:"
read USERNAME
FIND_USER
#if no user create one
if [[ -z $USER ]]
  then
  CREATE_USER
  else
  echo -e "\nWelcome back, $USER! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo -e "\nGuess the secret number between 1 and 1000:"
read GUESS

#add a games_played + 1
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME'")

while [[ $GUESS -ne $SECRET_NUMBER ]]
do
  if [[ $GUESS != [0-9]* ]]
    then
    echo "That is not an integer, guess again:"
    read GUESS
    ((NUMBER_OF_GUESSES++))

  elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then 
    echo "It's higher than that, guess again:"
    read GUESS
    ((NUMBER_OF_GUESSES++))

  elif [[ $GUESS -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
    ((NUMBER_OF_GUESSES++))
    fi
done

if [[ $BEST_GAME -eq 0 ]] || [[ $BEST_GAME -gt $NUMBER_OF_GUESSES ]]
  then
  UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username='$USERNAME'")
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
}

PLAY_GAME