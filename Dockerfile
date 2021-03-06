FROM debian:latest

RUN useradd -ms /bin/bash drozer

# Install all dependencies
RUN apt-get update && \
    apt-get install -y wget openjdk-7-jre-headless libc6-i386 lib32stdc++6 && \
    apt-get -y install bash-completion python2.7 python-dev python-protobuf python-openssl python-twisted && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install android tools + sdk
ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH $PATH:${ANDROID_HOME}/tools:$ANDROID_HOME/platform-tools

# Set up insecure default key
RUN mkdir -m 0750 /.android
ADD files/insecure_shared_adbkey /.android/adbkey
ADD files/insecure_shared_adbkey.pub /.android/adbkey.pub

RUN wget -qO- "http://dl.google.com/android/android-sdk_r24.3.4-linux.tgz" | tar -zx -C /opt && \
    echo y | android update sdk --no-ui --all --filter platform-tools --force

# Switch to drozer's home directory
WORKDIR /home/drozer

# Download the console
RUN wget -c 'https://www.mwrinfosecurity.com/system/assets/931/original/drozer_2.3.4.deb'

# Install the console
RUN dpkg -i drozer_2.3.4.deb
RUN rm *.deb

RUN apt-get install -y zlib1g

RUN dpkg --add-architecture i386
RUN apt-get update
RUN apt-get -y install zlib1g:i386

RUN rm /tmp/adb.log

# Run as drozer user
#USER drozer

# Download agent
RUN wget -c 'https://www.mwrinfosecurity.com/system/assets/934/original/drozer-agent-2.3.4.apk'

# Download sieve
RUN wget -c 'https://www.mwrinfosecurity.com/system/assets/380/original/sieve.apk'

# Port forwarding required by drozer
# RUN echo 'adb forward tcp:31415 tcp:31415' >> /home/drozer/.bashrc

# Alias for Drozer
# RUN echo "alias drozer='drozer console connect'" >> /home/drozer/.bashrc

