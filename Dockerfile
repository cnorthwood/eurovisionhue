FROM ruby:3
RUN bundle config --global frozen 1

WORKDIR /app

COPY Gemfile Gemfile.lock /app/

RUN bundle install

COPY eurovisionhue.rb LICENSE README.md /app/
COPY flags /app/flags/

RUN useradd -s /bin/bash -d /app eurovisionhue
RUN chown -Rfv eurovisionhue: /app

USER eurovisionhue
CMD ["bundle", "exec", "ruby", "eurovisionhue.rb"]
