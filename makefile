
DEVICE ?= cu.usbmodem11301
SKETCH ?= test


compile:
	arduino-cli compile -p /dev/${DEVICE} --fqbn arduino:avr:uno -v -t sketches/${SKETCH}

upload:
	arduino-cli upload -p /dev/${DEVICE} --fqbn arduino:avr:uno -v sketches/${SKETCH}

deploy:
	make compile 
	make upload

compile_zig:
	cd zig && zig build

upload_zig:
	arduino-cli upload -p /dev/${DEVICE} --fqbn arduino:avr:uno --input-file zig/zig-out/firmware/robot.hex

deploy_zig:
	make compile_zig
	make upload_zig

monit:
	arduino-cli monitor -p /dev/${DEVICE}