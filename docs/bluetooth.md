# Connect Bluetooth Mouse & Keyboard

Notes on connecting a Logitech M720 Triathlon mouse and Keychron K2 Pro keyboard
to a Dell T3610 with a Bluetooth 4.0 USB dongle.

https://nixos.wiki/wiki/bluetooth

Neither would connect through GNOME settings. Used CLI:
```sh
$ bluetoothctl
[bluetooth] # power on
[bluetooth] # agent on
[bluetooth] # default-agent
[bluetooth] # scan on
[bluetooth] # pair [hex-address]
[bluetooth] # connect [hex-address]
[bluetooth] # trust [hex-address]
```

Keyboard would need to be re-paired every time

```sh
/etc/bluetooth🔒 took 2m48s ❯ bluetoothctl --agent KeyboardDisplay
Agent registered

[M720 Triathlon]# info 6C:93:08:61:69:A1
Device 6C:93:08:61:69:A1 (public)
	Name: Keychron K2 Pro
	Alias: kb
	Class: 0x00000540
	Icon: input-keyboard
	Paired: yes
	Bonded: no
	Trusted: yes
	Blocked: no
	Connected: yes
	WakeAllowed: yes
	LegacyPairing: no
	UUID: Service Discovery Serve.. (00001000-0000-1000-8000-00805f9b34fb)
	UUID: Human Interface Device... (00001124-0000-1000-8000-00805f9b34fb)
	UUID: PnP Information           (00001200-0000-1000-8000-00805f9b34fb)
	Modalias: usb:v3434p0220d0130
```

Deleted Keyboard from Gnome Bluetooth settings and reconnected through the same GUI.

```sh
[CHG] Device 6C:93:08:61:69:A1 ServicesResolved: no
[CHG] Device 6C:93:08:61:69:A1 Paired: no
[CHG] Device 6C:93:08:61:69:A1 Connected: no
[DEL] Device 6C:93:08:61:69:A1 kb

[CHG] Controller 00:1A:7D:DA:71:11 Discovering: no
[CHG] Device 6C:93:08:61:69:A1 Connected: yes
[CHG] Device 6C:93:08:61:69:A1 Bonded: yes
[CHG] Device 6C:93:08:61:69:A1 Modalias: usb:v3434p0220d0130
[CHG] Device 6C:93:08:61:69:A1 UUIDs: 00001000-0000-1000-8000-00805f9b34fb
[CHG] Device 6C:93:08:61:69:A1 UUIDs: 00001124-0000-1000-8000-00805f9b34fb
[CHG] Device 6C:93:08:61:69:A1 UUIDs: 00001200-0000-1000-8000-00805f9b34fb
[CHG] Device 6C:93:08:61:69:A1 ServicesResolved: yes
[CHG] Device 6C:93:08:61:69:A1 Paired: yes
[CHG] Device 6C:93:08:61:69:A1 WakeAllowed: yes
[CHG] Device 6C:93:08:61:69:A1 Trusted: yes
[CHG] Controller 00:1A:7D:DA:71:11 Discovering: yes

[M720 Triathlon]# devices 
Device 24:29:34:BB:C5:E7 Matt's Pixel Buds Pro
Device E9:08:F2:E4:60:AA M720 Triathlon
Device 23:01:01:AA:04:D0 L7161
Device 6C:93:08:61:69:A1 Keychron K2 Pro
[M720 Triathlon]# info 6C:93:08:61:69:A1
Device 6C:93:08:61:69:A1 (public)
	Name: Keychron K2 Pro
	Alias: Keychron K2 Pro
	Class: 0x00002540
	Icon: input-keyboard
	Paired: yes
	Bonded: yes
	Trusted: yes
	Blocked: no
	Connected: yes
	WakeAllowed: yes
	LegacyPairing: no
	UUID: Service Discovery Serve.. (00001000-0000-1000-8000-00805f9b34fb)
	UUID: Human Interface Device... (00001124-0000-1000-8000-00805f9b34fb)
	UUID: PnP Information           (00001200-0000-1000-8000-00805f9b34fb)
	Modalias: usb:v3434p0220d0130
[CHG] Device 6C:93:08:61:69:A1 ServicesResolved: no
[CHG] Device 6C:93:08:61:69:A1 Connected: no
[CHG] Device 6C:93:08:61:69:A1 Class: 0x00000540
[CHG] Device 6C:93:08:61:69:A1 Icon: input-keyboard
[CHG] Device 6C:93:08:61:69:A1 Connected: yes
[CHG] Device 6C:93:08:61:69:A1 Connected: no
[DEL] Device 23:01:01:AA:04:D0 L7161
[CHG] Device 6C:93:08:61:69:A1 Connected: yes
[CHG] Device 6C:93:08:61:69:A1 Connected: no
[CHG] Device 6C:93:08:61:69:A1 Connected: yes
[CHG] Device 6C:93:08:61:69:A1 Connected: no
[CHG] Device 6C:93:08:61:69:A1 Connected: yes
[CHG] Device 6C:93:08:61:69:A1 ServicesResolved: yes
```

Keyboard is now listed as `Bonded` but still needs to be re-paired on every connection.
