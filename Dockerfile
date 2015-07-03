FROM	ruby
MAINTAINER	roygobeil.antoine@gmail.com

# Update
RUN apt-get -y update

RUN mkdir /opt/app

# Install dep
ADD Gemfile /opt/app/
ADD Gemfile.lock /opt/app/

# Install dependencies
RUN cd /opt/app; bundle install --binstubs # --deployment

# Add src
ADD . /opt/app

CMD ["/opt/app/bin/thin","-c","/opt/app","-e","development","-p","4000","start"]
