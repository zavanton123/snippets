# Spring Aspect Oriented Programming (AOP)

### Main.java
package org.example.springintro;

import org.example.springintro.service.PersonService;
import org.springframework.context.annotation.*;

@EnableAspectJAutoProxy
@PropertySource("classpath:application.properties")
@Configuration
@ComponentScan
public class Main {

    public static void main(String[] args) {
        AnnotationConfigApplicationContext context =
                new AnnotationConfigApplicationContext(Main.class);

        PersonService personService = context.getBean(PersonService.class);
        System.out.println(personService.getByName("Tom").getName());
    }
}



### LoggingAspect.java
package org.example.springintro.aspect;

import org.aspectj.lang.JoinPoint;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Before;
import org.springframework.stereotype.Component;

@Aspect
@Component
public class LoggingAspect {

    @Before("execution(* org.example.springintro.dao.*.*(..))")
    public void logCalls(JoinPoint joinPoint) {
        System.out.println("LOGGING DAO CALL");
        String name = joinPoint.getSignature().getName();
        Object[] args = joinPoint.getArgs();
        System.out.println("name: " + name);
    }
}




### PersonDaoSimple.kt
package org.example.springintro.dao

import org.example.springintro.data.Person
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service

@Service("myPerson")
class PersonDaoSimple : PersonDao {

    @Value("\${defaultAge}")
    val myAge = 0

    override fun findByName(name: String): Person {
        return Person(name)
    }
}
