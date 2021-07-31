# Looper, Handler, Message Queue
- This is a producer/consumer pattern


### ActivityThread.java
public class ActivityThread {
    public static void main(String[] args){
        ...
        // UI thread Looper and MessageQueue created
        Looper.prepareMainLooper();
        
        ...
        // Infinite loop is run
        Looper.loop();
    }
}




### Looper.java
public class Looper {
    // all threads have the same instance of ui thread looper
    static Looper sMainLooper;
    
    // each thread has its own instance of thread local looper
    static final ThreadLocal<Looper> sThreadLocal = new ThreadLocal<Looper>();
    
    final MessageQueue mQueue;
    
    private Looper() {
        mQueue = new MessageQueue();
    }
    
    // main thread looper is created only once
    // this method is only called in ActivityThread.main()
    public void prepareMainLooper(){
        sMainLooper = myLooper();
    }
    
    // any thread get access main thread looper
    public static Looper getMainLooper() {
        return sMainLooper;
    }

    // thread local looper is created every time for each new thread with a looper
    public static void prepare() {
        // looper and message queue are created 
        // by calling the looper's private constructor
        sThreadLocal.set(new Looper());
    }
    
    // each thread can access its own thread local looper
    public static Looper myLooper() {
        return sThreadLocal.get();
    }
    
    // This method is called in ActivityThread.main()
    public static void loop() {
        // UI thread gets main looper
        // other threads get their loopers
        Looper looper = myLooper();
        MessageQueue queue = looper.mQueue;
        
        // Infinite loop to process the messages
        while(true){
            // this is a blocking call
            Message message = queue.next();
            
            // We get handler via message.target reference
            // the handler dispatches the message
            message.target.dispatchMessage(message);
        }
    }
}



### Handler.java
public class Handler {
    // Handler has reference to Looper of some thread
    private Looper looper;
    
    public Handler(Looper looper){
        this.looper = looper;
    }
    
    // Handler posts messages to the MessageQue via the Looper
    public void post(Message message){
        looper.getMessageQueue().enqueueMessage(message);
    }
    
    // this is called in Looper.loop() method
    public void dispatchMessage(Message msg) {
        if (msg.callback != null) {
            handleCallback(msg.callback);
        } else {
            handleMessage(msg);
        }
    }
    
    public void handleCallback(Runnable callback){
        callback.run();
    }
    
    // Must be implemented by subclasses
    public void handleMessage(@NonNull Message message) {
        // some message handling here...
    }
}


### Some other thread code
// Pass some thread's looper reference to the handler's constructor
Handler handler = new Handler(Looper.getMainLooper());

// define the callback to be run by the handler in the Looper.loop()
Message message = new Message();
message.target = handler;
message.callback = new Runnable(){
    @Override
    public void run() {
        // this code is run on the UI thread in Looper.loop()
        Toast.makeText(someContext, "Hello world", Toast.LENGTH_SHORT).show();
    }
};

handler.post(message);

