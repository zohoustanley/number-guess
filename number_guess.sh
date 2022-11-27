#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
NUMBER_TO_GUESS=$(( $RANDOM % 1000 ))
echo "Enter your username:"
read USERNAME
if [[ ${#USERNAME} -gt 2 ]]; 
  then
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME' ");
    if [[ -z $USER_ID ]]
      then
      SAVED_USERNAME=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')" )
      USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME' ");
      echo -e "\nWelcome, $USERNAME! It looks like this is your first time here.";
    else
      USER_DATA=$($PSQL "SELECT min(number_of_guesses) AS best_game, count(game_id) as games_played FROM games INNER JOIN users USING(user_id) WHERE users.user_id=$USER_ID GROUP BY users.user_id");
      echo "$USER_DATA" | while IFS="|" read best_game games_played
      do
          echo "Welcome back, $USERNAME! You have played $games_played games, and your best game took $best_game guesses."
      done
    fi
    
    echo -e "\nGuess the secret number between 1 and 1000:"
    read SECRET_NUMBER

    i=1
    while [[ "$SECRET_NUMBER" != "$NUMBER_TO_GUESS" ]]
    do
      i=$((i+1))
        if [[ "$SECRET_NUMBER" =~ ^[0-9]+$ ]]
          then
          if [[ "$SECRET_NUMBER" > "$NUMBER_TO_GUESS" ]]
            then echo -e "It's lower than that, guess again:"
            read SECRET_NUMBER
          elif [[ "$SECRET_NUMBER" < "$NUMBER_TO_GUESS" ]]
            then echo -e "It's higher than that, guess again:"
            read SECRET_NUMBER
          else
            exit
          fi
        else
            echo -e "\nThat is not an integer, guess again:"
            read SECRET_NUMBER
        fi
    done
    echo -e "You guessed it in $i tries. The secret number was $NUMBER_TO_GUESS. Nice job!"
    SAVED_GAMES=$($PSQL "INSERT INTO games(number_of_guesses, user_id) VALUES($i, $USER_ID) ");
    
else
    # Show message when not enough characters
    echo -e "\nYou need to provide at least 22 characters" ;  
fi