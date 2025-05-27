#!/bin/bash

# Execute first script
echo "Running setup.sh..."
./setup.sh

# Wait for 10 seconds
echo "Waiting for 10 seconds..."
sleep 10

# Execute second script
echo "Running cleaning.sh..."
./cleanup.sh
