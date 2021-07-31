# Android Internals
Source: https://www.youtube.com/watch?v=0zJCyKp7-9s


### Android Kernel
It is based on Linux Kernel.
The kernel is responsible for:
- CPU management
- Memory management
- Processes management


### Android Kernel modifications:
- Binder IPC (/dev/binder)

- Low Memory Killer (LMK) (vs Linux Out Of Memory Killer)
(Android LMK score is set in User space) 
(Linux OOM score is set in Kernel space)

- Wakelocks (put the device into dormant state for battery efficiency)
(If you need the device to be awake, you acquire the lock)
(If you may let the device go to sleep, you release the lock)





### 'Init' process
Executes init.rc
When the device is turned on, the kernel starts the 'init' process
- It is the first user space process
- It is the root of all other processes
(The Process Id (PID) of init process is always 1)
- It mounts directories (/dev, /sys, /proc, etc.)
- It starts daemons: Zygote, adbd, installd, logd, servicemanager


### Daemon processes
- installd (install/uninstall apps)
- adbd (Android Debug Bridge)
- servicemanager (registers all system services, i.e. ActivityManagerService, etc.)
- Zygote 
- etc.


### Zygote process (daemon)
- It is used to launch apps faster
- It is a process with pre-initialized environment (Android runtime, java classes, resources, etc.)
- Regular linux process is called with 'fork()' (copy is created) and then 'exec()' (its resources are cleaned)
- But Zygote is only called with fork(), not exec() (i.e. its resources are not cleaned)
- Classes and resources are shared between apps, so they initialized only once


### Processes and UIDs
- Android uses Linux's user ids (UIDs)
- Every app is a user (i.e. every app has a UID)





### Binder IPC (Inter Process Communication)
Idea: App1 lacks some permission, and App2 has this permission
App1 sends a callback via Binder to App2 (i.e. Binder.transact())
App2 executes the callback and sends back the result 
to App1 via Binder (i.e. Binder.onTransact())

Note: any data is wrapped into Parcels (marshal/unmarshal VS serialize/deserialize)

App1 --> aidl --> Binder/IBinder
                --> Kernel (Binder Module)
                    --> Binder/IBinder --> aidl --> App2

For simplicity - AIDL tool is used, it is a bridge, it creates:
- a 'Proxy' on the App1 side
- a 'Stud' on the App2 side


at App1: (*.aidl -> Java Interface --> call Proxy.someMethod() -> call Binder.transact()

at Kernel: --> syscall to Kernel (/dev/binder) --> syscall from Kernel to App2

at App2: --> call Binder.onTransact() --> call Stud.someMethod()







### System Server
It is a process started by 'init' and forked from 'Zygote'
System Server starts many services 
(i.e. ActivityManagerService, WindowManagerService, PackageManagerService, etc.)
Note: ActivityManager has a 'stack' of 'tasks' (i.e. app processes)
Note: PackageManager resolves explicit and implicit intents.




### Activities and Processes
ActivityManager -< Stack -< App1 Task -< MainActivityRecord ('stopped) + SecondActivityRecord ('resumed')
Note: ActivityManager manages the lifecycle of apps activities




### OOM Adjustments
ActivityManager gives each process an OOM score
which is later used by the Kernel to kill the old process.
Each time something happens (activity is opened, closed, etc.) 
the relevant OOM score is recalculated.
