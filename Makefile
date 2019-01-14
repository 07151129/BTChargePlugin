.PHONY: clean

all: BTCharge

BTCharge: bt_charge.m
	cc -framework Foundation -framework IOBluetooth -fobjc-arc bt_charge.m -Os -bundle \
	-o BTCharge -arch x86_64

install: BTCharge
	cp -r BTCharge.plugin /Library/Audio/Plug-Ins/HAL/
	cp BTCharge /Library/Audio/Plug-Ins/HAL/BTCharge.plugin/Contents/MacOS/

clean:
	rm BTCharge
