TITLE=pam_storepw

LIBSRC = $(TITLE).c
LIBOBJ = $(TITLE).o
LDLIBS = -lpam -lpam_misc
LIBSHARED = $(TITLE).so


####################### don't edit below #######################

all: $(LIBSHARED)

$(LIBSHARED): $(LIBOBJ)
		ld --shared -o $@ $(LIBOBJ) $(LDLIBS)

clean:
	rm -f $(LIBOBJ) $(LIBSHARED) core *~

extraclean: clean
	rm -f *.a *.o *.so *.bak 

.c.o:	
	$(CC) $(CFLAGS) -c $< -o $@
