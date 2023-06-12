FROM harbor.k8s.libraries.psu.edu/library/ruby-3.1.2-node-16:20230612 as base
ENV GA_TRACKING_ID=GA-123456789
WORKDIR /app

ENV TZ=America/New_York

RUN apt-get update && apt-get install --no-install-recommends mariadb-client libmariadbclient-dev libsqlite3-dev -y

RUN useradd -u 10000 app -d /app
RUN chown -R app /app

COPY Gemfile* /app/
RUN chown -R app /app

USER app
RUN gem install bundler:2.3.5
RUN bundle install --path vendor/bundle

COPY --chown=app . /app

CMD ["/app/bin/startup"]

# Final Target
FROM base as production
ENV PARTNER=graduate

RUN RAILS_ENV=production SECRET_KEY_BASE=$(bundle exec rails secret) bundle exec rails assets:precompile

CMD ["/app/bin/startup"]
