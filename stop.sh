#!/bin/bash
# Stop and remove the VendorQuote container

set -e

echo "Stopping VendorQuote container..."

if docker ps -a | grep -q vendorquote; then
  docker rm -f vendorquote
  echo "✓ Container removed"
else
  echo "No VendorQuote container found"
fi
