# See README for compiler options
CFLAGS= -Ofast  -pthread -D WITH_RTL -D WITH_ALSA -D WITH_SNDFILE `pkg-config --cflags librtlsdr`
LDLIBS= -lm -pthread  -lasound -lsndfile `pkg-config --libs librtlsdr`

# Airspy conf 
# CFLAGS= -Ofast -pthread -D WITH_AIR -I.  `pkg-config --cflags libairspy`
# LDLIBS= -lm -pthread  `pkg-config --libs libairspy` -lusb-1.0

# RTL only conf
#CFLAGS= -Ofast -pthread -D WITH_RTL -I.  `pkg-config --cflags librtlsdr`
#LDLIBS= -lm -pthread   -lrtlsdr `pkg-config --libs librtlsdr`

acarsdec:	acarsdec.o acars.o msk.o rtl.o air.o output.o alsa.o soundfile.o
	$(CC) acarsdec.o acars.o msk.o rtl.o air.o output.o alsa.o soundfile.o -o $@ $(LDLIBS)

acarsserv:	acarsserv.o dbmgn.o
	$(CC) -Ofast acarsserv.o dbmgn.o -o $@ -lsqlite3

acarsdec.o:	acarsdec.c acarsdec.h
acars.o:	acars.c acarsdec.h syndrom.h
msk.o:	msk.c acarsdec.h
output.o:	output.c acarsdec.h
rtl.o:	rtl.c acarsdec.h
acarsserv.o:	acarsserv.h
dbmgm.o:	acarsserv.h

clean:
	@\rm -f *.o acarsdec acarsserv

install: acarsdec
	cp acarsdec /usr/local/bin
	cp acarsdec.service /lib/systemd/system
	sudo systemctl enable acarsdec
	sudo groupadd acarsdec
	sudo useradd acarsdec -g acarsdec -s /usr/bin/nologin

install_serv: acarsserv
	cp acarsserv /usr/local/bin
	cp acarsserv.conf /etc/init
	sudo service acarsserv start
