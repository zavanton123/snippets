# Spring Java Based Config

### pom.xml
```

<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.example</groupId>
    <artifactId>SpringIntro</artifactId>
    <version>1.0-SNAPSHOT</version>

    <properties>
        <maven.compiler.source>8</maven.compiler.source>
        <maven.compiler.target>8</maven.compiler.target>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>5.3.9</version>
        </dependency>
    </dependencies>

</project>
```


### Main.java
package org.example.springintro;

import org.example.springintro.config.AppConfig;
import org.example.springintro.service.PersonService;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;

public class Main {
    public static void main(String[] args) {
//        ClassPathXmlApplicationContext context =
//                new ClassPathXmlApplicationContext("context.xml");

        AnnotationConfigApplicationContext context =
                new AnnotationConfigApplicationContext(AppConfig.class);

        PersonService personService = context.getBean(PersonService.class);
        System.out.println(personService.getByName("Mike").getName());
    }
}



### PersonService.java
package org.example.springintro.service;

import org.example.springintro.data.Person;

public interface PersonService {
    Person getByName(String name);
}



### PersonServiceImpl.java
package org.example.springintro.service;

import org.example.springintro.dao.PersonDao;
import org.example.springintro.data.Person;

public class PersonServiceImpl implements PersonService {
    private PersonDao personDao;

    public PersonServiceImpl(PersonDao personDao) {
        this.personDao = personDao;
    }

    @Override
    public Person getByName(String name) {
        return personDao.findByName(name);
    }
}




### PersonDao.java
package org.example.springintro.dao;

import org.example.springintro.data.Person;

public interface PersonDao {
    Person findByName(String name);
}




### PersonDaoSimple.java
package org.example.springintro.dao;

import org.example.springintro.data.Person;

public class PersonDaoSimple implements PersonDao {
    private int defaultAge;

    @Override
    public Person findByName(String name) {
        return new Person(name);
    }

    public void setDefaultAge(int defaultAge) {
        this.defaultAge = defaultAge;
    }

    public int getDefaultAge() {
        return defaultAge;
    }
}




### Person.java
package org.example.springintro.data;

public class Person {
    private String name;

    public Person(String name) {
        this.name = name;
    }

    public String getName() {
        return this.name;
    }
}




### AppConfig.java
package org.example.springintro.config;

import org.example.springintro.dao.PersonDao;
import org.example.springintro.service.PersonService;
import org.example.springintro.service.PersonServiceImpl;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Import;

@Import(PersonConfig.class)
@Configuration
public class AppConfig {

    @Bean
    public PersonService personService(PersonDao personDao) {
        return new PersonServiceImpl(personDao);
    }
}




### PersonConfig.java
package org.example.springintro.config;

import org.example.springintro.dao.PersonDao;
import org.example.springintro.dao.PersonDaoSimple;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class PersonConfig {
    @Bean
    public PersonDao personDao(@Value("23") int age) {
        PersonDaoSimple personDao = new PersonDaoSimple();
        personDao.setDefaultAge(age);
        return personDao;
    }
}
