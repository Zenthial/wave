FROM rust

COPY entry.sh /entry.sh

RUN cargo install rojo

ENTRYPOINT ["/entry.sh"]