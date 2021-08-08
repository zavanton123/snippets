# Spring Events

### CustomEvent.java
package ru.zavanton.demo.mykdemo.events;

import org.springframework.context.ApplicationEvent;

public class CustomEvent extends ApplicationEvent {
    private String message;

    public CustomEvent(Object source, String message) {
        super(source);
        this.message = message;
    }

    public String getMessage() {
        return message;
    }
}










### CustomEventPublisher.java
package ru.zavanton.demo.mykdemo.events;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationEventPublisher;
import org.springframework.stereotype.Component;

@Component
public class CustomEventPublisher {
    private ApplicationEventPublisher publisher;

    @Autowired
    public CustomEventPublisher(ApplicationEventPublisher publisher) {
        this.publisher = publisher;
    }

    public void publish(String info) {
        CustomEvent event = new CustomEvent(this, info);
        publisher.publishEvent(event);
    }
}









### CustomEventListener.java
package ru.zavanton.demo.mykdemo.events;

import org.springframework.context.ApplicationListener;
import org.springframework.stereotype.Component;

@Component
public class CustomEventListener implements ApplicationListener<CustomEvent> {

    @Override
    public void onApplicationEvent(CustomEvent event) {
        System.out.println("RECEIVED THE EVENT: " + event.getMessage());
    }
}











### MyService.java
package ru.zavanton.demo.mykdemo.service;

import org.springframework.stereotype.Service;
import ru.zavanton.demo.mykdemo.dao.IMyDao;
import ru.zavanton.demo.mykdemo.events.CustomEventPublisher;

@Service
public class MyService implements IMyService {
    private IMyDao myDao;
    private CustomEventPublisher publisher;

    public MyService(
            IMyDao myDao,
            CustomEventPublisher publisher
    ) {
        this.myDao = myDao;
        this.publisher = publisher;
    }

    @Override
    public String load() {
        publisher.publish("this is my custom event");
        return myDao.fetch();
    }
}
