FROM fluent/fluentd:v0.14.14-onbuild
MAINTAINER Steve Sloka <slokas@upmc.edu>

COPY /start.sh /home/fluent/start.sh

ENV PATH /home/fluent/.gem/ruby/2.3.0/bin:$PATH

# !! root access required to read container logs !!
USER root
RUN apk --no-cache --update add build-base ruby-dev && \
    gem install fluent-plugin-s3 && \
    gem install fluent-plugin-elasticsearch && \
    rm -rf /root/.gem/ruby/2.3.0/cache/*.gem && gem sources -c && \
    apk del build-base ruby-dev && rm -rf /var/cache/apk/*

ENTRYPOINT ["sh", "start.sh"]
