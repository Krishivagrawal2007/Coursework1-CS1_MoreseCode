DEV = /dev/ttyUSB0
MCU = atmega328p

%.hex: %.s
	@echo "Building $<..."
	avr-as -g -mmcu=$(MCU) -o $*.o $<
	avr-ld -o $*.elf $*.o
	avr-objcopy -O ihex -R .eeprom $*.elf $@
	avrdude -C /etc/avrdude.conf -p $(MCU) -c arduino -P $(DEV) -D -U flash:w:$*.hex:i

clean:
	-rm -f *.hex *.o *.elf

.PHONY: clean
