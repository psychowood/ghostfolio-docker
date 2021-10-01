FROM node:14-alpine3.14
RUN apk --no-cache add curl xdg-utils

ENV USER=ghostfolio
ENV UID=1100
ENV GROUP=ghostfolio
ENV GID=1100

RUN addgroup -g "$GID" "$GROUP"

WORKDIR /ghostfolio/tmp
WORKDIR /.cache

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/ghostfolio/tmp" \
    --ingroup "$GROUP" \
    --no-create-home \
    --uid "$UID" \
    "$USER"

RUN chown "$USER":"$GROUP" -vR /ghostfolio /.cache

USER "$USER"

WORKDIR /scripts

COPY --chown="$USER":"$GROUP" scripts/* ./
RUN chmod +x *.sh

WORKDIR /ghostfolio

ENTRYPOINT 
CMD ["echo", "Nothing to run here."]

VOLUME ["/ghostfolio"]
