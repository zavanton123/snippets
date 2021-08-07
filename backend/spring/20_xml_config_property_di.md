# Spring XML configuration

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


### /src/main/resources/context.xml
```
<?xml version="1.0" encoding="UTF-8"?>
<beans xmlns="http://www.springframework.org/schema/beans"
       xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
       xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

    <bean id="personDao" class="org.example.springintro.PersonDao"/>

    <bean id="personService" class="org.example.springintro.PersonServiceImpl">
        <property name="dao" ref="personDao"/>
        <!--        <constructor-arg name="personDao" ref="personDao"/>-->
    </bean>
</beans>
```


### Main.java
package org.example.springintro;

import org.springframework.context.support.ClassPathXmlApplicationContext;

public class Main {
    public static void main(String[] args) {
        ClassPathXmlApplicationContext context =
                new ClassPathXmlApplicationContext("context.xml");
        PersonService personService = context.getBean(PersonService.class);
        System.out.println(personService.getByName("Mike").getName());
    }
}



### PersonService.java
package org.example.springintro;

public interface PersonService {
    Person getByName(String name);
}



### PersonServiceImpl.java
package org.example.springintro;

public class PersonServiceImpl implements PersonService {
    private PersonDao personDao;

    public void setDao(PersonDao personDao) {
        this.personDao = personDao;
    }

//    public PersonServiceImpl(PersonDao personDao) {
//        this.personDao = personDao;
//    }

    @Override
    public Person getByName(String name) {
        return personDao.findByName(name);
    }
}



### PersonDao.java
package org.example.springintro;

public class PersonDao {
    public Person findByName(String name) {
        return new Person(name);
    }
}



### Person.java
package org.example.springintro;

public class Person {
    private String name;

    public Person(String name) {
        this.name = name;
    }

    public String getName() {
        return this.name;
    }
}

