# Stage 1: Download Godot headless
FROM ubuntu:22.04 AS godot-download

ARG GODOT_VERSION=4.5-stable

# Install wget and unzip
RUN apt-get update && \
    apt-get install -y wget unzip && \
    rm -rf /var/lib/apt/lists/*

# Download and extract Godot headless
WORKDIR /tmp
RUN wget https://github.com/godotengine/godot/releases/download/${GODOT_VERSION}/Godot_v${GODOT_VERSION}_linux.x86_64.zip && \
    unzip Godot_v${GODOT_VERSION}_linux.x86_64.zip && \
    chmod +x Godot_v${GODOT_VERSION}_linux.x86_64

# Stage 2: Runtime image
FROM ubuntu:22.04

# Install minimal runtime dependencies for Godot headless
# Only the essentials needed for a server without graphics/audio
RUN apt-get update && \
    apt-get install -y \
    libstdc++6 \
    ca-certificates \
    libfontconfig1 \
    libfreetype6 \
    && rm -rf /var/lib/apt/lists/*

# Copy Godot executable from download stage
COPY --from=godot-download /tmp/Godot_v4.5-stable_linux.x86_64 /usr/local/bin/godot

# Create app directory
WORKDIR /app

# Copy game files
COPY --chown=root:root . /app/

# Remove directories that shouldn't be in the image
RUN rm -rf /app/executables /app/logs /app/.git

# Create logs directory for runtime
RUN mkdir -p /app/logs

# Import assets in headless mode
# This generates .godot/imported/ and .godot/uid_cache.bin
# Using --import to properly generate UID cache (see godotengine/godot#107695)
RUN /usr/local/bin/godot --headless --path /app --import || true

# Default port for game server (can be overridden)
EXPOSE 8080

# Headless mode is the default
# Expected arguments:
#   server_type=room
#   environment=production
#   code=ABC123
#   port=18000
#   --lobby_url=ws://game-lobby:17018 (optional, for Docker networking)
ENTRYPOINT ["/usr/local/bin/godot", "--headless", "--path", "/app"]
CMD ["server_type=room"]
