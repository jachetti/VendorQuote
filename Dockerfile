# VendorQuote Docker Image
# INTENTIONALLY INSECURE FOR TRAINING PURPOSES
# This image contains deliberate security issues for educational demonstration

FROM node:16-bullseye

# Set working directory
WORKDIR /app

# Install required system utilities for runtime commands
RUN apt-get update && apt-get install -y \
    bash \
    curl \
    wget \
    netcat-openbsd \
    procps \
    coreutils \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy package files (no external dependencies needed)
COPY package.json ./

# INTENTIONAL SECURITY ISSUE: Using ADD instead of COPY
# This triggers image assessment finding: ADDInstructionInDockerfile
ADD app/ /app/app/
ADD server.js /app/

# Copy configuration and fake sensitive data
# INTENTIONAL SECURITY ISSUE: Embedding secrets in image
COPY config/ /app/config/
COPY keys/ /app/keys/
COPY data/ /app/data/
COPY backup/ /app/backup/

# INTENTIONAL SECURITY ISSUE: Exposing privileged port
# This triggers image assessment finding: PrivilegedPortFoundInImage
EXPOSE 80

# INTENTIONAL SECURITY ISSUE: No USER instruction
# This triggers image assessment findings:
# - RunningAsRootContainer
# - UserInstructionNotInDockerfile
# Container will run as root user (UID 0)

# Start the application
CMD ["node", "server.js"]
