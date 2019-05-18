FROM ruby:latest

WORKDIR /cli

COPY . /cli

RUN bundle

CMD ["bundle", "exec", "ruby", "eurovisionhue.rb"]