#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

RANDOM_NUMBER=$(( RANDOM % 1000 ))

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]; then
  # user doesn't exists
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_NEW_USER_OUTPUT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
  # user exists
  USER_INFO=$($PSQL "SELECT username, games_played, best_game FROM users WHERE username='$USERNAME'")
  echo "$USER_INFO" | while IFS="|" read USERNAME GAMES_PLAYED BEST_GAME
  do
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  done
fi

# add game played
UPDATE_GAMES_PLAYED=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username = '$USERNAME';")

echo "Guess the secret number between 1 and 1000:"
read GUESS
TRIES=1

while [[ $GUESS -ne $RANDOM_NUMBER ]]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    read GUESS
  elif [[ $GUESS -gt $RANDOM_NUMBER ]]; then
    echo "It's lower than that, guess again:"
    read GUESS
  elif [[ $GUESS -lt $RANDOM_NUMBER ]]; then
    echo "It's higher than that, guess again:"
    read GUESS
  fi
  ((TRIES++))
done

echo "You guessed it in $TRIES tries. The secret number was $RANDOM_NUMBER. Nice job!"

# get best game
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")

# check if this game is greater than the best
if [[ $TRIES -lt $BEST_GAME || $BEST_GAME -eq 0 ]]; then
  # new best game
  UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $TRIES WHERE username = '$USERNAME';")
fi
