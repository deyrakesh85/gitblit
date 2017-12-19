FROM openjdk:jre

MAINTAINER Rakesh Dey, <deyrakesh85@gmail.com>

ENV GITBLIT_VERSION 1.8.0

#System Update

RUN apt-get update \
&& apt-get dist-upgrade -y \
&& apt-get install -y git-core sudo wget \
&& apt-get clean \
&& rm -Rf /var/lib/apt/lists/*

# Installing Gitblit

WORKDIR /opt
RUN wget -O /tmp/gitblit.tar.gz http://dl.bintray.com/gitblit/releases/gitblit-${GITBLIT_VERSION}.tar.gz \
&& tar xzf /tmp/gitblit.tar.gz \
&& rm -f /tmp/gitblit.tar.gz \
&& ln -s gitblit-${GITBLIT_VERSION} gitblit \
&& mv gitblit/data gitblit-data-initial \
&& mkdir gitblit-data \

#Add User and Group

&& groupadd -r -g 500 gitblit \
&& useradd -r -d /opt/gitblit-data -u 500 -g 500 gitblit


# Adjust the default Gitblit settings to bind to 8080, 8443, 9418, 29418, and allow RPC administration.

RUN echo "server.httpPort=8080" >> gitblit-data-initial/gitblit.properties \
&& echo "server.httpsPort=8443" >> gitblit-data-initial/gitblit.properties \
&& echo "web.enableRpcManagement=true" >> gitblit-data-initial/gitblit.properties \
&& echo "web.enableRpcAdministration=true" >> gitblit-data-initial/gitblit.properties \
&& echo "server.contextPath=/gitblit" >> gitblit-data-initial/gitblit.properties

# Setup the Docker container environment and run Gitblit

VOLUME /opt/gitblit-data
EXPOSE 8080 8443 9418 29418

WORKDIR /opt/gitblit

RUN echo "#!/bin/bash if [ ! -f /opt/gitblit-data/gitblit.properties ]; then cp -Rf /opt/gitblit-data-initial/* /opt/gitblit-data/ fi if [ -z "$JAVA_OPTS" ]; then JAVA_OPTS="-server -Xmx1024m" fi chown -Rf gitblit:gitblit /opt/gitblit-data exec sudo -u gitblit java $JAVA_OPTS -Djava.awt.headless=true -jar /opt/gitblit/gitblit.jar --baseFolder /opt/gitblit-data" >> run.sh

RUN chmod 755 /opt/gitblit/run.sh

CMD /opt/gitblit/run.sh