# MAINTAINER Aitor Carrera <aitor.carrera@edosoft.es>

# STAGE para bundle y asset precompile
FROM ruby:2.4.4-alpine3.7 as builder

ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true

RUN apk add --no-cache \
  build-base \
  busybox \
  ca-certificates \
  curl \
  git \
  gnupg1 \
  graphicsmagick \
  libffi-dev \
  libsodium-dev \
  nodejs=8.9.3-r1 \
  openssh-client \
  postgresql-dev \
  rsync \
  linux-headers \
  shared-mime-info

RUN mkdir -p /app
WORKDIR /app

# Esto se copia antes que el codigo para que el cache
# de construccion se pueda usar si cambiiamos rl codiigo pero no las
# dependencias (trucazo!)
COPY Gemfile /app/
COPY Gemfile_custom /app/
COPY Gemfile.lock /app/

# Ojo que en development habia alguna dependencia que me haciia falta
# RUN bundle install --without development test -j4 --retry 3 \
#  && rm -rf /usr/local/bundle/bundler/gems/*/.git \
#    /usr/local/bundle/cache/

RUN bundle install -j4 --retry 3 \
  && rm -rf /usr/local/bundle/bundler/gems/*/.git \
    /usr/local/bundle/cache/

COPY . /app/
# Truco para el asset sin BBDD
RUN mv db/schema.rb db/schema.rb.true
RUN touch db/schema.rb
# RUN bundle exec rake \
#   DATABASE_ADAPTER=nulldb \
#   SECRET_TOKEN=adummytoken \
#   LISTEN_ON=0.0.0.0:8000 \
#   RAILS_ENV=production \
#   DATABASE=db \
#   DATABASE_USER=user \
#   DATABASE_PASS=pass \
#   assets:precompile


# Packaging final app w/o node_modules & the development tools
FROM ruby:2.4.4-alpine3.7

ENV RAILS_ENV production
ENV RAILS_SERVE_STATIC_FILES true
ENV RAILS_LOG_TO_STDOUT true

# Seguro que alguna dep de estas sobra
RUN apk add --no-cache \
  busybox \
  ca-certificates \
  curl \
  gnupg1 \
  graphicsmagick \
  libsodium-dev \
  nodejs=8.9.3-r1 \
  postgresql-dev \
  rsync \
  file \
  imagemagick

RUN mkdir -p /app

WORKDIR /app

# Copiamos las dependencias y la app con los assets.
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=builder /app/ /app/
ADD ./dockerfiles/start.sh /app/dockerfiles/start.sh
RUN chmod +x /app/dockerfiles/start.sh

EXPOSE 3000

ENTRYPOINT ["/app/dockerfiles/start.sh"]
