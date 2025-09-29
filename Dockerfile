FROM debian:bullseye

# Update and install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        curl \
        python3 \
        python3-pip \
        python3-dev \
        build-essential \
        sudo \
        pkg-config \
        ca-certificates \
        locales \
        tzdata \
        golang \
        fontconfig \
        gcc \
        cron \
        ffmpeg \
    && dpkg-reconfigure locales \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set up the download directories
RUN mkdir -p /Music/SoundCloud/lukas-wolter-779075141

# Set up the locale environment
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Install SCDL from PyPI (latest release)
RUN pip install --no-cache-dir scdl

# Set up the timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Validate SCDL installation
RUN scdl --version

# Create a crontab file for the user
RUN echo "0 0 * * * scdl -f -c --onlymp3 -l https://soundcloud.com/lukas-wolter-779075141 --path /Music/SoundCloud/lukas-wolter-779075141 --debug >> /Music/SoundCloud/lukas-wolter-779075141.log 2>&1" > /crontab.txt \
 && crontab /crontab.txt \
 && rm /crontab.txt

# Run initial download once, then start cron in foreground
CMD ["sh", "-c", "scdl -f -c --onlymp3 -l https://soundcloud.com/lukas-wolter-779075141 --path /Music/SoundCloud/lukas-wolter-779075141 --debug >> /Music/SoundCloud/lukas-wolter-779075141.log 2>&1 && cron -f"]
