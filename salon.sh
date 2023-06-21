#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

# Display the services offered
SERVICES=$(echo "$($PSQL 'SELECT service_id, name FROM services')" | sed 's/ |//')
echo -e "\nWelcome to My Salon, how can I help you?\n"

echo "$SERVICES" | while read SERVICE_ID SERVICE_NAME
do
  echo "$SERVICE_ID) $SERVICE_NAME"
done

# Prompt for service selection
echo ""
echo "What would you like today?"
read SERVICE_ID_SELECTED

# Validate service selection
while [[ $($PSQL "SELECT COUNT(*) FROM services WHERE service_id = $SERVICE_ID_SELECTED") -eq 0 ]]
do
  echo -e "\nI could not find that service. What would you like today?"

  echo "$SERVICES" | while read SERVICE_ID SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo ""
  echo "What would you like today?"
  read SERVICE_ID_SELECTED
done

# Prompt for phone number
echo ""
echo "What's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

# If customer doesn't exist, prompt for name and insert into customers table
if [[ -z $CUSTOMER_ID ]]
then
  echo ""
  echo "I don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME

  # Validate the name input
  while [[ ! $CUSTOMER_NAME =~ ^[A-Za-z]+$ ]]; do
    echo "Invalid name format. Please enter a valid name (alphabets only)."
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    echo ""
  done

  INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
fi

# Prompt for appointment time
SERVICE_NAME_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
echo ""
echo "What time would you like your $SERVICE_NAME_SELECTED, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
read SERVICE_TIME

# Insert appointment into appointments table
INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

# Retrieve service name
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

# Display confirmation message
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g').\n"
