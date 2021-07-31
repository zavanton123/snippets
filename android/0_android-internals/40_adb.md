# Android Debug Bridge

### Location
```
~/Android/Sdk/platform-tools/adb
```

### Adb is a server-client application
- A client, which sends commands. The client runs on your development machine. 

- A daemon (adbd), which runs commands on a device. 
The daemon runs as a background process on each device.

- A server, which manages communication between the client and the daemon. 
The server runs as a background process on your development machine.
The port is 5037


### Enable USB debugging on your device


# ADB commands
### Get help
```
adb --help
```

### Show all devices
```
adb devices
```

### Show all devices with additional info
### this outputs the 'serial numbers' of available devices and emulators
```
adb devices -l
```

### Send commands to specific device
### indicate the serial number with '-s'
### or set the env variable $ANDROID_SERIAL
```
adb -s emulator-5554 install HelloWorld.apk
```

### Send commands to the emulator (if only one is connected)
```
adb -e install HelloWorld.apk
```

### Send commands to the device (if only one is connected)
```
adb -d install HelloWorld.apk
```

### Install apk to device
```
adb install ~/Desktop/HelloWorld.apk
```

### Uninstall application
```
adb uninstall com.example.demoadb
```

### Show logcat logs
```
adb logcat -d
adb logcat 
```

### Clear logcat logs
```
adb logcat -c
```

### Setup port forwarding
### (i.e. forward host 1234 port to device 4321 port)
```
adb forward tcp:1234 tcp:4321
```

### Pull files from device / Push files to device
```
adb push ~/Desktop/hello.txt /storage/emulated/0/Download
adb pull /storage/emulated/0/Download/hello.txt ./some-folder
```

### Stop the ADB server
### The server is restarted when you make any adb command
```
adb kill-server
```

### Issue shell commands
```
adb -e shell ls -la
adb shell ps 
```

### Access ActivityManager
```
adb shell
am help
```

### Example: start some activity with ActivityManager
```
adb shell am start -a android.intent.action.VIEW
```

### Example: start my app activity via ActivityManager:
```
adb shell am start \
    -c api.android.intent.LAUNCHER \
    -a api.android.category.MAIN 
    -n com.example.demoadb/com.example.demoadb.MainActivity
```

### Access PackageManage
```
adb shell
pm help
```

### Example: uninstall app via package manager
```
adb shell
pm uninstall com.example.demoadb
```

### Show all packages
```
adb shell pm list packages
```

### Show all permission groups
```
adb shell pm list permission-groups
adb shell pm list permissions
adb shell pm list features
```


### Run SQL commands via shell

```
adb shell
sqlite3 /data/data/com.example.myapp1/databases/hello-world.db
```











### 'emulator' command
### location:
```
~/Android/Sdk/tools/emulator
```

### Show available emulators
```
emulator -list-avds
```
