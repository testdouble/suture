FROM ruby:2.2

RUN mkdir -p /usr/src/app

COPY ./Gemfile /usr/src/app
COPY ./suture.gemspec /usr/src/app
COPY ./lib/suture/version.rb /usr/src/app/lib/suture/

WORKDIR /usr/src/app

RUN bundle install

COPY . /usr/src/app/

CMD ["rake"]
