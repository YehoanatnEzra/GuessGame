#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Globals
max=0
max_attempts=0
SCORE_FILE=""
target=0
attempts=0
start_time=0
timeout_seconds=60
no_hints=false
player_name=""
difficulty=""
score=0

# Functions

print_intro() {
    echo -e "${CYAN}Welcome to 'Guess the Number'!${NC}"
    read -p "Enter your name: " player_name
    echo "Choose difficulty: easy / medium / hard"
    read -p "Difficulty: " difficulty
}

set_difficulty() {
    case "$difficulty" in
        easy)
            max=10
            max_attempts=5
            SCORE_FILE="highscore_easy.txt"
            ;;
        medium)
            max=100
            max_attempts=10
            SCORE_FILE="highscore_medium.txt"
            ;;
        hard)
            max=1000
            max_attempts=12
            SCORE_FILE="highscore_hard.txt"
            no_hints=true
            ;;
        *)
            echo -e "${RED}Invalid difficulty. Restart and choose: easy / medium / hard${NC}"
            exit 1
            ;;
    esac
}

start_game() {
    target=$(( RANDOM % max + 1 ))
    attempts=0
    start_time=$(date +%s)
    echo -e "${YELLOW}I'm thinking of a number between 1 and $max."
    echo "You have $max_attempts tries and $timeout_seconds seconds!${NC}"
}

check_timeout() {
    local current_time=$(date +%s)
    local elapsed=$(( current_time - start_time ))
    if [ $elapsed -ge $timeout_seconds ]; then
        echo -e "${RED} Time's up! You took more than $timeout_seconds seconds.${NC}"
        echo " Game over. The number was: $target"
        exit 1
    fi
}

handle_guess() {
    read -p "Guess #$((attempts+1)): " guess

    if ! [[ "$guess" =~ ^[0-9]+$ ]]; then
        echo -e "${RED} Invalid input! Enter a number.${NC}"
        return
    fi

    ((attempts++))

    if [ "$guess" -eq "$target" ]; then
        local current_time=$(date +%s)
        local elapsed=$(( current_time - start_time ))
        echo -e "${GREEN}  Correct! You guessed it in $attempts tries and $elapsed seconds.${NC}"

        score=$(( (max_attempts - attempts + 1) * 10 ))

        echo "$player_name - $score points in $attempts tries ($elapsed sec)" >> "$SCORE_FILE"
        echo -e "${CYAN} Score saved to $SCORE_FILE${NC}"

        echo -e "${YELLOW} High Scores for $difficulty:${NC}"
        sort -t'-' -k2 -nr "$SCORE_FILE" | head -n 3
        exit 0
    else
        if [ "$no_hints" = true ]; then
            echo -e "${RED}  Wrong! Try again.${NC}"
        else
            if [ "$guess" -lt "$target" ]; then
                echo " Too low!"
            else
                echo " Too high!"
            fi
        fi
    fi
}

main_loop() {
    while [ $attempts -lt $max_attempts ]; do
        check_timeout
        handle_guess
    done

    echo -e "${RED} Out of tries! The number was: $target${NC}"
}


print_intro
set_difficulty
start_game
main_loop

