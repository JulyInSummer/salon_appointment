#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e $1
  fi
  # List of services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  read SERVICE_ID_SELECTED

  # if invalid id is entered
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
  else
    # if input is valid integer
    APPOINTMENT "$SERVICE_ID_SELECTED"
  fi
}


APPOINTMENT() {
  # ensuring that select service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1")
  # send to main menu if doesn't exist
  if [[ -z $SERVICE_NAME ]]
  then
    MAIN_MENU "\nI could not find that service. What would you like today?"
  else
    # removing all the whitespaces
    SERVICE_ID_SELECTED=$(echo $SERVICE_ID_SELECTED | sed 's/ //g')
    SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/ //g')

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
    # if customer doesn't exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      # getting a name and creating new customer
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    fi
    # removing all the whitespaces 
    CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/ //g')
    # getting customer id for creating an appointment
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME' AND phone='$CUSTOMER_PHONE'")
    # removing all the whitespaces 
    CUSTOMER_ID=$(echo $CUSTOMER_ID | sed 's/ //g')
    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

MAIN_MENU "Welcome to My Salon, how can I help you?\n"