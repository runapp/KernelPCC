obj-m += tcp_TA.o
KVERSION := $(shell uname -r)
KVERSION2 := $(shell echo $(KVERSION) | sed 's/-default//')
KPATH := /usr/src/linux-$(KVERSION2)
PWD := $(shell pwd)

default: tcp_TA.ko

tcp_TA.ko: .prepared
	make -C $(KPATH) SUBDIRS=$(PWD) modules

prepare: .prepared
.prepared:
	zypper in -n kernel-devel kernel-default-devel kernel-source
	zcat /boot/symvers-$(KVERSION).gz > $(KPATH)/Module.symvers
	make -C $(KPATH) cloneconfig
	make -C $(KPATH) modules_prepare
	touch .prepared

install: tcp_TA.ko
	cp tcp_TA.ko /lib/modules/$(KVERSION)
	depmod -a
	@echo -n "Insmod at boot time? (y/n)[n] "; \
	read answer ; \
	if [ "x$$answer" == "xy" ] ; then \
		echo tcp_TA > /etc/modules-load.d/99tcp_TA.conf ; \
	fi

clean:
	make -C $(KPATH) M=$(PWD) clean

veryclean: clean
	rm .prepared
