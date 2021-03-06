WORKDIR /tmp

ENV PATH=/usr/local/cargo/bin:$PATH

RUN git clone https://github.com/ogham/exa \
    && cd exa \ {{- if use_apk }}
        && cargo build --release \
    {{- else }}
        && /root/.cargo/bin/cargo build --release \
    {{- endif }}
    && mv target/release/exa /usr/local/bin/exa \
    && curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to /usr/local/bin/ \
    && rm -rf /tmp/exa

COPY entrypoint/entrypoint.sh /entrypoint
COPY entrypoint/scripts /entrypoint.d/
COPY bins/ /usr-bins/
RUN chmod +x /entrypoint.d/*.sh /entrypoint /usr-bins/* \
    && mv /usr-bins/* /usr/local/bin/ \
    && mkdir -p /var/log/supervisord

{{ if use_apk }}
RUN apk del .build-deps .nginx-rundeps
{{ else }}
RUN rm -rf /var/lib/apt/lists/* \
    && apt-get remove -y \
        autoconf \
        automake \
        cmake \
        g++ \
        gcc \
        gettext \
        golang-go\
        libtool \
        make \
    && /root/.cargo/bin/rustup self uninstall -y
{{ endif }}


ENTRYPOINT ["/entrypoint"]

{{- if is_web }}
EXPOSE 80 443 9003
{{- endif }}

WORKDIR /app