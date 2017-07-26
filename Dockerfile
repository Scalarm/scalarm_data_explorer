FROM ubuntu:latest
SHELL ["/bin/bash", "-l", "-c"]

ENV SCALARM_HOME /scalarm

RUN apt-get update
RUN apt-get install -y curl git r-base-core

RUN curl -sSL https://get.rvm.io | bash -s stable
RUN source /etc/profile.d/rvm.sh

RUN rvm requirements
RUN rvm install 2.1
RUN gem install bundler

ADD . $SCALARM_HOME

WORKDIR $SCALARM_HOME

EXPOSE 3001

RUN bundle config git.allow_insecure true
RUN bundle install

CMD /bin/bash -l -c "rake service:start"
