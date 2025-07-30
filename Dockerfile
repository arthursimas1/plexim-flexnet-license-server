# download stage
#########################################
FROM ubuntu:22.04 AS download

# URL to the PLEXIM FlexNet license manager tarball
ARG PLEXIM_FLEXNET_URL=https://www.plexim.com/sites/default/files/dstlm/flexnet_11_18_3_1_linux64.tar.gz

RUN apt-get -y update
RUN apt-get -y install wget

WORKDIR /tmp/flexlm-license-manager
RUN wget --progress=bar:force -- $PLEXIM_FLEXNET_URL
RUN tar -zxvf ./*.tar.gz
RUN rm ./*.tar.gz

# runtime setup stage
#########################################
FROM ubuntu:22.04 AS runtime
RUN apt-get -y update
RUN apt-get -y install lsb-core

WORKDIR /opt/flexlm-license-manager/

# add the flexnet commands to $PATH
ENV PATH="$PATH:/opt/flexlm-license-manager/"

COPY --from=download /tmp/flexlm-license-manager/* ./

# setup user and permissions
#########################################
RUN ln -s /tmp /usr/tmp
RUN chmod 1777 /usr/tmp

RUN adduser --system --group --no-create-home flexlm

RUN mkdir /var/log/flexlm
RUN chgrp flexlm /var/log/flexlm
RUN chmod g+w /var/log/flexlm

RUN chmod +x lmgrd

USER flexlm

# volumes
#########################################
VOLUME ["/var/flexlm"]

# expose ports
#########################################
EXPOSE 27000-27009

# entrypoint
#########################################
COPY ./entrypoint.sh /usr/local/bin/
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
