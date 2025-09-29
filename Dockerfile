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
    && apt-get clean

# Create system link to python3
# RUN ln -s /usr/bin/python3 /usr/bin/python
RUN pip install .

# Set up the download directories
RUN mkdir -p /Music/SoundCloud/lukas-wolter-779075141

# Set up the cron environment
RUN mkdir /etc/crontabs

# Set up the locale environment
ENV LC_ALL=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US.UTF-8

# Clone the scdl repository
RUN git clone https://github.com/flyingrub/scdl.git

# Change the working directory
WORKDIR /scdl

# Install the package
RUN python setup.py install

# Set up the timezone
ENV TZ=Europe/Berlin
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# Validate SCDL
RUN scdl --version

# Create a crontab file
RUN echo "0 0 * * * scdl -f -c --onlymp3 -l https://soundcloud.com/lukas-wolter-779075141 --path /Music/SoundCloud/lukas-wolter-779075141 --debug >> /Music/SoundCloud/lukas-wolter-779075141.log 2>&1" > /crontab.txt \
 && crontab /crontab.txt \
 && rm /crontab.txt

# Run the cron job on container startup and then start cron daemon
CMD ["sh", "-c", "scdl -f -c --onlymp3 -l https://soundcloud.com/lukas-wolter-779075141 --path /Music/SoundCloud/lukas-wolter-779075141 --debug >> /Music/SoundCloud/lukas-wolter-779075141.log 2>&1 \
    && cron -f"]
