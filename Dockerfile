FROM fluent/fluentd:v0.12-debian
MAINTAINER Ken Howard <howardkr@upmc.edu>

ENV PATH /home/fluent/.gem/ruby/2.3.0/bin:$PATH

# !! root access required to read container logs !!
USER root

RUN buildDeps="sudo make gcc g++ libc-dev ruby-dev libffi-dev" \
    && apt-get update \
    && apt-get install -y --no-install-recommends $buildDeps \
    && echo 'gem: --no-document' >> /etc/gemrc \
    && gem install \
        ffi \
        fluent-plugin-cloudwatch-logs \
        fluent-plugin-elasticsearch \
        fluent-plugin-kubernetes_metadata_filter \
        fluent-plugin-record-reformer \
        fluent-plugin-rewrite-tag-filter:1.5.6 \
        fluent-plugin-s3:'~> 0.8' \
        fluent-plugin-secure-forward \
        fluent-plugin-systemd:0.0.8 \
    && gem sources --clear-all \
    && SUDO_FORCE_REMOVE=yes \
        apt-get purge -y --auto-remove \
        -o APT::AutoRemove::RecommendsImportant=false $buildDeps \
    && rm -rf \
        /tmp/* \
        /usr/lib/ruby/gems/*/cache/*.gem \
        /var/lib/apt/lists/* \
        /var/tmp/*

# Copy plugins
COPY plugins /fluentd/plugins/
COPY /start.sh /home/fluent/start.sh

ENTRYPOINT ["bin/sh", "/home/fluent/start.sh"]
