#!/bin/bash
# Number Guessing Game

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Generate Random Number between 1 and 1000
RAND_NUM=$(( RANDOM % 1000 + 1 ))

# Prompt user for username
echo "Enter your username:"
read USERNAME

if [ ${#USERNAME} -ge 23 ]
then
    echo "Username must be no more than 22 characters."
else
    # Check username against DB
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")

    # New User Check
    if [[ -z $USER_ID ]]
    then
        # Welcome new user
        echo "Welcome, $USERNAME! It looks like this is your first time here."
        INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
        USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
    else
        # Existing user greeting
        GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id = '$USER_ID'")
        BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id = '$USER_ID'")
        echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
    fi

    echo "Guess the secret number between 1 and 1000:"
    read GUESS
    TRIES=1

    while [ $GUESS != $RAND_NUM ]
    do
        if [[ ! $GUESS =~ ^[0-9]+$ ]]
        then
            echo "That is not an integer, guess again:"
        elif [[ $GUESS -gt $RAND_NUM ]]
        then
            echo "It's lower than that, guess again:"
        elif [[ $GUESS -lt $RAND_NUM ]]
        then
            echo "It's higher than that, guess again:"
        fi
        
        read GUESS
        TRIES=$((TRIES+1))
    done

    echo "You guessed it in $TRIES tries. The secret number was $RAND_NUM. Nice job!"
    GAMES_PLAYED=$((GAMES_PLAYED+1))
    if [[ -z $BEST_GAME ]]
    then
        BEST_GAME=$TRIES
    elif (( $TRIES < $BEST_GAME ))
    then
        BEST_GAME=$TRIES
    fi
    UPDATE_SCORE=$($PSQL "UPDATE users SET (games_played, best_game)=($GAMES_PLAYED,$BEST_GAME) WHERE user_id = $USER_ID")

fi