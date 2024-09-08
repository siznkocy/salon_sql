#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -X -tc"

# get the services

MAIN_MENU(){
# list the services.
  GET_SERVICES

# read selected service.
  read SERVICE_ID_SELECTED

# valid the selected service
  SELECT_SERVICE $SERVICE_ID_SELECTED

}

GET_SERVICES(){

  # Get all available services

  AVAILABLE_SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")

  if [[ -z $AVAILABLE_SERVICES ]]
  then
    echo "No available services at the time!"
  else
    # echo $AVAILABLE_SERVICES
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME
    do
      MSG "$SERVICE_ID) $NAME"
    done
  fi
}

SELECT_SERVICE(){
  # $1: SERVICE_ID_SELECTED

  # Validate the selected service.
  SERVICE=$($PSQL "SELECT name FROM services WHERE service_id=$1")

  if [[ -z $SERVICE ]]
  # loop to main menu.
  then
    MSG "\nI could not find that service. What would like today?"
    MAIN_MENU
  else
    USER_RECORDS $SERVICE $1
  fi
}

USER_RECORDS(){
  # $2: SERVICE_ID_SELECTED

  MSG "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # valid customer

  if [[ -z $CUSTOMER_NAME ]]
  then
  # pass "customer phone number" & "service name" to function below.
    RECORD_USER_INFO $CUSTOMER_PHONE $2 $CUSTOMER_NAME
  else
    APPOINTMENT $CUSTOMER_NAME $CUSTOMER_PHONE $2
  fi
}

RECORD_USER_INFO(){
  # $1: CUSTOMER_PHONE $2:SERVICE_ID_SELECTED
  MSG "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  # recod user details
  RECORDED_USER=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$1')" )
  if [[ -z $RECORDED_USER ]]
  then
    MSG "ERROR! {RECORD_USER_INFO}: customer might exist!"
  else
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$1'")
    APPOINTMENT $CUSTOMER_NAME $1 $2
  fi

}

APPOINTMENT(){
  # $1:CUSTOMER_NAME,
  # $2:CUSTOMER_PHONE
  # $3:SERVICE_ID_SELECTED 

  MSG "\nWhat time would you like your cut, $1?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$2'")
  MAKE_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID', '$3', '$SERVICE_TIME')" )
  if [[ -z $MAKE_APPOINTMENT ]]
  then
    MSG ""ERROR! {APPOINTMENT}: ""
  else
    
    MSG "\nI have put you down for a cut at $SERVICE_TIME, $1."
  fi
}

MSG(){
  echo -e $1
}

MSG "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU
