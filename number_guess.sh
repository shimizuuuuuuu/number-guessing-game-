#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUMBER=$(( RANDOM % 1000 + 1 ))

echo "Enter your username:"

read USERNAME

while [[ ${#USERNAME} -gt 22 ]]
do 
  echo "Username must be 22 characters or less."
  echo "Enter your username:"
  read USERNAME
done

USER_EXIST=$($PSQL "SELECT username FROM users WHERE username='$USERNAME'")

if [[ -n $USER_EXIST ]]
then 
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME'")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
fi

echo "Guess the secret number between 1 and 1000:"
read NUMBER

NUMBER_GUESSED=1

while [[ ! $NUMBER =~ ^[0-9]+$ ]] || [ [$NUMBER -lt 1 ]] || [[ $NUMBER -gt 1000 ]] 
do
  echo "That is not an integer, guess again:"
  read NUMBER
done

while [[ $NUMBER -ne $RANDOM_NUMBER ]]
do
  if [[ $NUMBER -lt $RANDOM_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  elif [[ $NUMBER -gt $RANDOM_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
  fi

  read NUMBER 

  while [[ ! $NUMBER =~ ^[0-9]+$ ]] || [[ $NUMBER -lt 1 ]] || [[ $NUMBER -gt 1000 ]]
  do
    echo "That is not an integer, guess again:"
    read NUMBER
  done
  
  NUMBER_GUESSED=$((NUMBER_GUESSED + 1))
done

if [[ $NUMBER -eq $RANDOM_NUMBER ]]
then 
  echo "You guessed it in $NUMBER_GUESSED tries. The secret number was $RANDOM_NUMBER. Nice job!"
  UPDATE_GAMES=$($PSQL "UPDATE users SET games_played = games_played + 1, best_game = LEAST(best_game, $NUMBER_GUESSED) WHERE username = '$USERNAME'")
fi  

    

