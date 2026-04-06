FROM harbor.k8s.libraries.psu.edu/library/ruby-3.4.9-node-22:20260406 AS base
ENV GA_TRACKING_ID=GA-123456789
WORKDIR /app

ENV TZ=America/New_York

RUN apt-get update && apt-get install --no-install-recommends mariadb-client libmariadb-dev libsqlite3-dev libyaml-dev -y

RUN useradd -u 10000 app -d /app
RUN chown -R app /app

COPY Gemfile* /app/
RUN chown -R app /app

USER app
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"
RUN bundle config set path 'vendor/bundle'
RUN bundle install

COPY --chown=app . /app

CMD ["/app/bin/startup"]

# Final Target
FROM base AS production
ENV PARTNER=graduate

RUN RAILS_ENV=production SECRET_KEY_BASE=$(bundle exec rails secret) bundle exec rails assets:precompile

CMD ["/app/bin/startup"]
