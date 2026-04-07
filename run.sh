#!/bin/bash
# Run the VendorQuote container

set -e

# Check if container is already running
if docker ps | grep -q vendorquote; then
  echo "VendorQuote container is already running."
  echo "Stop it first with: docker rm -f vendorquote"
  exit 1
fi

# Check if port 80 is in use
if lsof -Pi :80 -sTCP:LISTEN -t >/dev/null 2>&1 ; then
  echo "Port 80 is already in use."
  echo "Stop the conflicting service or change the port mapping."
  exit 1
fi

echo "Starting VendorQuote container..."
echo ""

docker run -d \
  --name vendorquote \
  -p 80:80 \
  vendorquote:worstcase

echo ""
echo "✓ VendorQuote is running!"
echo ""
echo "Access the app:"
echo "  - Local: http://127.0.0.1"
echo "  - Health check: http://127.0.0.1/healthz"
echo ""
echo "View logs:"
echo "  docker logs -f vendorquote"
echo ""
echo "Stop container:"
echo "  docker rm -f vendorquote"
