#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

RESULT() {
  if [[ $1 -eq 0 ]]
    then
      echo "I could not find that element in the database."
    else
      NUMBER=$1
      SYMBOL=$2
      TYPE=$3
      MASS=$4
      NAME=$5
      MELTING=$6
      BOILING=$7

      echo "The element with atomic number $NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
  fi
}

MAIN() {
  # if element.sh executed with no arguments, request argument
  if [[ -z $1 ]] 
    then
      echo "Please provide an element as an argument."
    else
      # if atomic number, symbol, or name used as argument, output the element's info

      USER_INPUT=$1

      NUMBER=0
      SYMBOL='_'
      TYPE='_'
      MASS=0
      NAME='_'
      MELTING=0
      BOILING=0

      # for atomic number
      if [[ $USER_INPUT =~ ^[0-9]+$ ]]
        then
          # if argument is a number, do this
          #echo "Argument is an atomic number."

          SEARCH_RESULT=$($PSQL "SELECT atomic_number FROM elements WHERE atomic_number=$USER_INPUT")
          if [[ ! -z $SEARCH_RESULT ]]
            then
              NUMBER=$USER_INPUT
              SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE atomic_number=$NUMBER")
              NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$NUMBER")
            fi

        elif [[ ${#USER_INPUT} -lt 3 ]]
          then
          # if argument is a symbol, do this
          #echo "Argument is a symbol."

          SEARCH_RESULT=$($PSQL "SELECT symbol FROM elements WHERE symbol='$USER_INPUT'")
          if [[ ! -z $SEARCH_RESULT ]]
            then
              NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol='$USER_INPUT'")
              SYMBOL=$USER_INPUT
              NAME=$($PSQL "SELECT name FROM elements WHERE atomic_number=$NUMBER")
            fi

        else
          # if argument is not a number or a symbol, assume it's a name and do this
          #echo "Argument is not a number or a symbol...it's probably a name."

          SEARCH_RESULT=$($PSQL "SELECT name FROM elements WHERE name='$USER_INPUT'")
          if [[ ! -z $SEARCH_RESULT ]]
            then
              NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name='$USER_INPUT'")
              SYMBOL=$($PSQL "SELECT symbol FROM elements WHERE name='$USER_INPUT'")
              NAME=$USER_INPUT
            fi
        fi

        TYPE=$($PSQL "SELECT types.type FROM types FULL JOIN properties USING(type_id) WHERE atomic_number=$NUMBER")
        MASS=$($PSQL "SELECT atomic_mass FROM properties WHERE atomic_number=$NUMBER")
        MELTING=$($PSQL "SELECT melting_point_celsius FROM properties WHERE atomic_number=$NUMBER")
        BOILING=$($PSQL "SELECT boiling_point_celsius FROM properties WHERE atomic_number=$NUMBER")

        RESULT $NUMBER $SYMBOL $TYPE $MASS $NAME $MELTING $BOILING
    fi
}

MAIN $1