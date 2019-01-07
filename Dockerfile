FROM openjdk:10-slim

ENV CANTALOUPE_VERSION=4.0.2
#ENV IMAGEMAGICK_VERSION=7.0.8-14

EXPOSE 8182

VOLUME /imageroot

# Update packages and install tools
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends wget unzip graphicsmagick curl imagemagick libopenjp2-tools ffmpeg python && \
    rm -rf /var/lib/apt/lists/*

# Run non privileged
RUN adduser --system cantaloupe

WORKDIR /tmp

#ImageMagick 7 install - re-evaluate once officially deprecated
#RUN cd /tools && \
#    wget http://imagemagick.org/download/releases/ImageMagick-$IMAGEMAGICK_VERSION.tar.xz && \
#    tar -xf ImageMagick-$IMAGEMAGICK_VERSION.tar.xz && \
#    cd ImageMagick-$IMAGEMAGICK_VERSION && \
#    ./configure --prefix /usr/local && \
#    make && \
#    make install && \
#    cd .. && \
#    ldconfig /usr/local/lib && \
#    rm -rf  ImageMagick*

# Get and unpack Cantaloupe release archive
RUN curl -OL https://github.com/medusa-project/cantaloupe/releases/download/v$CANTALOUPE_VERSION/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && mkdir -p /usr/local/ \
 && cd /usr/local \
 && unzip /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && ln -s cantaloupe-$CANTALOUPE_VERSION cantaloupe \
 && rm -rf /tmp/Cantaloupe-$CANTALOUPE_VERSION \
 && rm /tmp/Cantaloupe-$CANTALOUPE_VERSION.zip \
 && rm -rf /usr/local/cantaloupe-$CANTALOUPE_VERSION/deps

COPY docker-entrypoint.sh /usr/local/bin/
COPY cantaloupe.properties.tmpl /etc/cantaloupe.properties.tmpl
RUN mkdir -p /var/log/cantaloupe /var/cache/cantaloupe \
 && touch /etc/cantaloupe.properties \
 && chown -R cantaloupe /var/log/cantaloupe /var/cache/cantaloupe \
    /etc/cantaloupe.properties /usr/local/bin/docker-entrypoint.sh

USER cantaloupe
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["sh", "-c", "java -Dcantaloupe.config=/etc/cantaloupe.properties -Xmx2g -jar /usr/local/cantaloupe/cantaloupe-$CANTALOUPE_VERSION.war"]
