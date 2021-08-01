### Android Startup
CPU -> Boot ROM (piece of code) -> Bootloader -> Kernel -> Init -> Native Daemons -> 
-> AndroidRuntime (this is a cpp class) -> Zygote -> System Server -> App1, App2

### Types of communication
- Binder IPC (more at the higher level)
- Sockets (more at the lower level, e.g. NetworkService communicates with netd daemon)


### CPU
### ABI (Application Binary Interface):
- armeabi-v7a
- arm64-v8a
- x86
- x86_64

### Bootloader
### is used for initializing kernel


### Kernel
### Regular Linux features:
- Process management
- Memory management
- IO management
- etc.
### Android specific features:
- Binder IPC
- Power management (wake locks)
- Aggressive Low Memory Killer (VS regular Linux OOM Killer)
-- foreground process
-- visible process 
-- service process
-- cached process


### Init
### The file: init.rc
it triggers Zygote process and other native daemons



### Native Daemons
### Native Daemons communicate via Unix Domain Socket 
### with bootstrap services (i.e. NetworkService, StorageService, etc.)
- installd (used for installing/uninstalling apps)
(PackageManagerService communicates with installd via Unix Domain Socket)
- servicemanager (all the system services are registered here)
- vold
- netd
- rild
- keystore
- ...


### Android Runtime
- it is a cpp class that starts Zygote (which starts the System Server)
- Zygote socket is registered (/dev/socket/zygote)



### Zygote process
### It has:
- DalvikVM (or ART)
- Preloaded Classes
- ZygoteServer is running inside it
- start System Server

### How Zygote process creates a new App 1 process?
### ZygoteInit -> ZygoteServer.runSelectLoop() -> forkAndSpecialize() (i.e. creates new processes)



### SystemServer process
(note: its name is 'system')

- starts the main system services 
(ActivityManagerService, PackageManagerService, WindowManagerService, etc.) 

- registers the system services with the servicemanager

### How does it work?
ActivityManager -> send message to Zygote -> create process App1


### App 1 process 
### ActivityThread
ActivityThread.main() 
  Looper.prepareMainLooper() (this launches app's UI thread with Handler)
    Looper.loop()
