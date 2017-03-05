FROM ubuntu:12.04
# Install required packages
RUN apt-get update && apt-get upgrade -yq
RUN apt-get install -yq wget build-essential make tk8.5 libgv-tcl bison flex
RUN apt-get install -yq sudo

# Create mkdirhier util
RUN echo 'mkdir -p $@' > /usr/bin/mkdirhier && chmod +x /usr/bin/mkdirhier

# Download stuff
RUN cd /root && wget --no-check-certificate http://ivi.fnwi.uva.nl/tcs/pub/software/pga/pga-1.7.tar.gz
RUN cd /root && wget --no-check-certificate http://ivi.fnwi.uva.nl/tcs/pub/software/toolbus/toolbus-bundle-0.1.0.tar.gz
RUN cd /root && tar -xzf pga-1.7.tar.gz
RUN cd /root && tar -xzf toolbus-bundle-0.1.0.tar.gz

# Configure Makefile
RUN cd /root/pga-1.7 && sed -i 's/^PERL = .*/PERL = \$\(shell which perl\)/' Makefile
RUN cd /root/pga-1.7 && sed -i 's/^WISH = .*/WISH = \$\(shell which wish\)/' Makefile
RUN cd /root/pga-1.7 && sed -i 's/^TCLSH = .*/TCLSH = $\(shell which tclsh\)/' Makefile
RUN cd /root/pga-1.7 && sed -i 's/^TCLDOT =/TCLDOT = \/usr\/lib\/tcltk\/graphviz\//' Makefile
RUN cd /root/pga-1.7 && sed -i 's/^CURRENTDIR =.*/CURRENTDIR = $\(shell pwd\)/' Makefile
RUN cd /root/pga-1.7 && sed -i 's/^DOTFONTPATH =.*/DOTFONTPATH = \/usr\/share\/fonts\/truetype\/freefont\//' Makefile
RUN cd /root/pga-1.7 && sed -i 's/^INSTALL =.*/INSTALL =\/opt\/pga1-7\//' Makefile

# Install PGA toolkit
RUN cd /root/pga-1.7 && make && make install

# Install toolbus
RUN cd /root && cd /root/toolbus-bundle-0.1.0 && ./configure --prefix=/opt/pga1-7 && make && make install
RUN cp /opt/pga1-7/bin/* /opt/pga1-7/

#Fix bug in PGA toolset
COPY MSPfunc.pm /opt/pga1-7/lib/perl/

ENV PATH /opt/pga1-7/bin:$PATH
RUN adduser pga
RUN adduser pga sudo
RUN echo "pga:pga" | chpasswd
ENV HOME /pga
ENV PWD /pga
RUN mkdir /pga
USER pga
