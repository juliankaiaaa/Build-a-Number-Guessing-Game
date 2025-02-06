#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

DISPLAY() {
  echo -e "\n~~~~~ Number Guessing Game ~~~~~\n" 

  # Get username
  echo "Enter your username:"
  read USERNAME

  # Trim whitespace from username
  USERNAME=$(echo "$USERNAME" | sed 's/^[ \t]*//;s/[ \t]*$//')

  # Get user ID from the database
  USER_ID=$($PSQL "SELECT u_id FROM users WHERE name='$USERNAME'")

  # If user exists
  if [[ -n $USER_ID ]]; then
    # Get games played count
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE u_id=$USER_ID")

    # Get best game (minimum guesses)
    BEST_GUESS=$($PSQL "SELECT MIN(guesses) FROM games WHERE u_id=$USER_ID")

    echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GUESS guesses."
  else
    # If user is new
    echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."

    # Insert into users table
    INSERTED_TO_USERS=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")

    # Get new user ID
    USER_ID=$($PSQL "SELECT u_id FROM users WHERE name='$USERNAME'")
  fi

  GAME
}

GAME() {
  # Generate secret number
  SECRET=$((1 + RANDOM % 1000))

  # Guess counter
  TRIES=0

  echo -e "\nGuess the secret number between 1 and 1000:"

  while true; do
    read GUESS

    # If input is not a number
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
    # If correct guess
    elif [[ $GUESS -eq $SECRET ]]; then
      TRIES=$((TRIES + 1))
      echo -e "\nYou guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"

      # Insert into games table
      INSERTED_TO_GAMES=$($PSQL "INSERT INTO games(u_id, guesses) VALUES($USER_ID, $TRIES)")
      
      # Exit the game after winning
      exit 0
    # If guess is too low
    elif [[ $GUESS -lt $SECRET ]]; then
      TRIES=$((TRIES + 1))
      echo -e "\nIt's higher than that, guess again:"
    # If guess is too high
    else
      TRIES=$((TRIES + 1))
      echo -e "\nIt's lower than that, guess again:"
    fi
  done
}


DISPLAY
