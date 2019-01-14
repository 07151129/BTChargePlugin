#include <stdint.h>

#include <objc/runtime.h>

#include <Foundation/Foundation.h>
#include <IOBluetooth/IOBluetooth.h>

int New_SHP_PlugIn() {
    return 0;
}

IMP setBatteryPercentSingle, setBatteryLevel_orig;

/**
 * Called by IOBluetooth in /sbin/bluetoothaudiod when it receives AT+IPHONEACCEV over RFCOMM
 * channel for an HFP device.
 */
void setBatteryLevel(id self, SEL cmd, int32_t lvl) {
    setBatteryLevel_orig(self, cmd, lvl);
    NSLog(@"setBatteryLevel %d", lvl);

    IOBluetoothDevice* dev = [(IOBluetoothHandsFreeAudioGateway*)self device];
    if (dev && lvl <= 10)
        setBatteryPercentSingle(dev, @selector(setBatteryPercentSingle:), lvl * 10);
}

__attribute__ ((constructor))
int init() {
    setBatteryPercentSingle =
        [IOBluetoothDevice instanceMethodForSelector:@selector(setBatteryPercentSingle:)];
    if (!setBatteryPercentSingle) {
        NSLog(@"Failed to get @selector(setBatteryPercentSingle:)");
        return 1;
    }
    Method m = class_getInstanceMethod([IOBluetoothHandsFreeAudioGateway class],
        @selector(setBatteryLevel:));
    if (!m) {
        NSLog(@"Failed to get method setBatteryLevel:");
        return 1;
    }
    setBatteryLevel_orig = method_setImplementation(m, (IMP)setBatteryLevel);
    if (!setBatteryLevel_orig) {
        NSLog(@"Failed to hook setBatteryLevel");
        return 1;
    }
    return 0;
}
