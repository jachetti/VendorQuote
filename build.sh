#!/bin/bash
# Build the VendorQuote container image

set -e

echo "Building VendorQuote container image..."
echo "This may take a few minutes on first build."
echo ""

docker build -t vendorquote:worstcase .

echo ""
echo "✓ Build complete!"
echo ""
echo "Image: vendorquote:worstcase"
echo ""
echo "Next steps:"
echo "  - Run: ./run.sh"
echo "  - Or use docker-compose: docker-compose up -d"
