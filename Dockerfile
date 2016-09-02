FROM ruby:2.2

RUN mkdir -p /usr/app/src

COPY ./Gemfile /usr/app/src
COPY ./suture.gemspec /usr/app/src
COPY ./lib/suture/version.rb /usr/app/src/lib/suture/

WORKDIR /usr/app/src

RUN bundle install

CMD ["rake"]
