#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER=$(( (RANDOM % 1000) + 1 ))

echo "Enter your username:"
read USERNAME

USER=$($PSQL "SELECT name FROM users WHERE name='$USERNAME';")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME'")

if [[ -z $USER ]]
  then
  $PSQL "INSERT INTO users(name, games_played, best_game, number_of_guesses) VALUES('$USERNAME', 0, 0, 0)"
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  else echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo $NUMBER
echo "Guess the secret number between 1 and 1000:"
read GUESS

$PSQL "UPDATE users SET games_played = games_played + 1 WHERE name='$USERNAME'"

while [[ $GUESS -ne $NUMBER ]]
do
  if [[ $GUESS != [0-9]* ]]
    then
    echo "That is not an integer, guess again:"
    read GUESS

  elif [[ $GUESS < $NUMBER ]]
    then 
    echo "It's higher than that, guess again:"
    read GUESS
    $PSQL "UPDATE users SET number_of_guesses = number_of_guesses + 1 WHERE name='$USERNAME'"

  elif [[ $GUESS > $NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    read GUESS
    $PSQL "UPDATE users SET number_of_guesses = number_of_guesses + 1 WHERE name='$USERNAME'"
    fi
done

$PSQL "UPDATE users SET number_of_guesses = number_of_guesses + 1 WHERE name='$USERNAME'"

NUMBER_OF_GUESSES=$($PSQL "SELECT number_of_guesses FROM users WHERE name='$USERNAME'")

if [[ $BEST_GAME == 0 || $BEST_GAME > $NUMBER_OF_GUESSES ]]
then
$PSQL "UPDATE users SET best_game = number_of_guesses"
fi

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $NUMBER. Nice job!"

$PSQL "UPDATE users SET number_of_guesses = 0 WHERE name='$USERNAME'"


