
DEVICE ?= cu.usbmodem11301
SKETCH ?= test


compile:
	arduino-cli compile -p /dev/${DEVICE} --fqbn arduino:avr:uno -v -t sketches/${SKETCH}

upload:
	arduino-cli upload -p /dev/${DEVICE} --fqbn arduino:avr:uno -v sketches/${SKETCH}

deploy:
	make compile 
	make upload

monit:
	arduino-cli monitor -p /dev/${DEVICE}