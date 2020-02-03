# TODO

## 20NRCTO1WW/Thinkpad L390

### 20NRCTO1WW: add fingerprint-gui; Synaptics Metallica MOH Touch Fingerprint Reader

tbd

### Make touchscreen work; Raydium Touchscreen; 

```bash
sudo modprobe hid-multitouch
sudo modprobe panel-raydium-rm68200 # ?
sudo modprobe raydium_i2c_ts # ?
xinput_calibrator --list # list the devices that can be calibrated
xinput_calibrator --device X # copy the result to /etc/X11/xorg.conf.d/99-calibration.conf as instructed
```

Ergebins: Funktioniert leider noch nicht.

`hwinfo`:

    39: None 00.0: 10002 LCD Monitor
      [Created at monitor.125]
      Unique ID: rdCR.wG4izYWCzu2
      Parent ID: _Znp.xwqYS8ptKo0
      Hardware Class: monitor
      Model: "AUO LCD Monitor"
      Vendor: AUO "AUO"
      Device: eisa 0x112d 
      Resolution: 1920x1080@60Hz
      Size: 293x165 mm
      Year of Manufacture: 2016
      Week of Manufacture: 20
      Detailed Timings #0:
         Resolution: 1920x1080
         Horizontal: 1920 1936 1952 2104 (+16 +32 +184) -hsync
           Vertical: 1080 1083 1097 1116 (+3 +17 +36) -vsync
        Frequencies: 141.00 MHz, 67.02 kHz, 60.05 Hz
      Config Status: cfg=new, avail=yes, need=no, active=unknown
      Attached to: #36 (VGA compatible controller)


### Make NFC work; NXP NFC

https://01.org/linux-nfc/documentation/hardware-support
https://github.com/nfc-tools/libnfc/issues/455#issuecomment-339608991
https://support.lenovo.com/partslookup
https://pcsupport.lenovo.com/de/de/products/laptops-and-netbooks/thinkpad-l-series-laptops/thinkpad-l390-type-20nr-20ns/20nr/parts/display/compatible (nach "NFC" suchen, liefert NPC300)

tbd
