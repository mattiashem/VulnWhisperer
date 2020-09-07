from ubuntu:latest


COPY install.sh /install.sh
RUN chmod +x /install.sh
RUN ./install.sh
