# Spring Bean Lifecycle

### Bean implements InitializingBean, DisposableBean
package ru.zavanton.demo.mykdemo.service;

import org.springframework.beans.factory.DisposableBean;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.stereotype.Service;

@Service
public class FirstService implements InitializingBean, DisposableBean {

    @Override
    public void afterPropertiesSet() throws Exception {
        System.out.println("myInit");
    }

    public String info() {
        return "info";
    }

    @Override
    public void destroy() throws Exception {
        System.out.println("myDestroy");
    }
}


### Bean uses @PostConstruct, @PreDestroy
package ru.zavanton.demo.mykdemo.service;

import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

@Service
public class SecondService {

    @PostConstruct
    public void myInit() {
        System.out.println("myInit");
    }

    public String info() {
        return "info";
    }

    @PreDestroy
    public void myDestroy() {
        System.out.println("myDestroy");
    }
}



### Bean implements ApplicationContextAware (BAD PRACTICE)
package ru.zavanton.demo.mykdemo.service;

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Service;

// Using context in beans is a BAD practice!!!
@Service
public class BadService implements ApplicationContextAware {

    private FirstService firstService;

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        firstService = applicationContext.getBean(FirstService.class);
    }

    public void showInfo() {
        System.out.println("Bad Service is showing info: " + firstService.info());
    }
}





### Bean injects application context via @Autowired (BAD PRACTICE)
package ru.zavanton.demo.mykdemo.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Service;

// Using context in beans is a BAD practice!!!
@Service
public class MoreBadService {

    private FirstService firstService;

    private ApplicationContext context;

    @Autowired
    public void setApplicationContext(ApplicationContext context) {
        this.context = context;
        firstService = context.getBean(FirstService.class);
    }

    public void showInfo() {
        System.out.println("MoreBadService is showing info: " + firstService.info());
    }
}



### Bean implements BeanPostProcessor, BeanFactoryPostProcessor
package ru.zavanton.demo.mykdemo.service;

import org.springframework.beans.BeansException;
import org.springframework.beans.factory.config.BeanPostProcessor;
import org.springframework.stereotype.Service;

@Service
public class CustomBeanPostProcessor implements BeanPostProcessor {

    @Override
    public Object postProcessBeforeInitialization(Object bean, String beanName) throws BeansException {
        System.out.println("Creating " + beanName);
        return bean;
    }

    @Override
    public Object postProcessAfterInitialization(Object bean, String beanName) throws BeansException {
        System.out.println("After creating " + beanName);
        return bean;
    }

    public String info() {
        return "info";
    }
}
