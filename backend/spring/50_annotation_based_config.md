# Spring Annotation Based Configuration

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
        <kotlin.version>1.5.21</kotlin.version>
    </properties>

    <dependencies>
        <dependency>
            <groupId>org.springframework</groupId>
            <artifactId>spring-context</artifactId>
            <version>5.3.9</version>
        </dependency>
        <dependency>
            <groupId>org.jetbrains.kotlin</groupId>
            <artifactId>kotlin-stdlib-jdk8</artifactId>
            <version>${kotlin.version}</version>
        </dependency>
        <dependency>
            <groupId>org.jetbrains.kotlin</groupId>
            <artifactId>kotlin-test</artifactId>
            <version>${kotlin.version}</version>
            <scope>test</scope>
        </dependency>
    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.jetbrains.kotlin</groupId>
                <artifactId>kotlin-maven-plugin</artifactId>
                <version>${kotlin.version}</version>
                <executions>
                    <execution>
                        <id>compile</id>
                        <phase>compile</phase>
                        <goals>
                            <goal>compile</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>test-compile</id>
                        <phase>test-compile</phase>
                        <goals>
                            <goal>test-compile</goal>
                        </goals>
                    </execution>
                </executions>
                <configuration>
                    <jvmTarget>1.8</jvmTarget>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <executions>
                    <execution>
                        <id>compile</id>
                        <phase>compile</phase>
                        <goals>
                            <goal>compile</goal>
                        </goals>
                    </execution>
                    <execution>
                        <id>testCompile</id>
                        <phase>test-compile</phase>
                        <goals>
                            <goal>testCompile</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

</project>
```



### Main.java
package org.example.springintro;

import org.example.springintro.dao.PersonDaoSimple;
import org.example.springintro.service.PersonService;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.PropertySource;

@PropertySource("classpath:application.properties")
@Configuration
@ComponentScan
public class Main {

    public static void main(String[] args) {
//        ClassPathXmlApplicationContext context =
//                new ClassPathXmlApplicationContext("context.xml");

//        AnnotationConfigApplicationContext context =
//                new AnnotationConfigApplicationContext(AppConfig.class);

        AnnotationConfigApplicationContext context =
                new AnnotationConfigApplicationContext(Main.class);

        PersonService personService = context.getBean(PersonService.class);
        System.out.println(personService.getByName("Tom").getName());

        PersonDaoSimple personDaoSimple = context.getBean(PersonDaoSimple.class);
        System.out.println(personDaoSimple.getMyAge());
    }
}




### PersonService.kt
package org.example.springintro.service

import org.example.springintro.data.Person

interface PersonService {

    fun getByName(name: String): Person
}



### PersonServiceImpl.kt
package org.example.springintro.service

import org.example.springintro.dao.PersonDao
import org.example.springintro.data.Person
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Service

// Note: the constructor is autowired by default
@Service
class PersonServiceImpl(
    @Qualifier("myPerson") private var personDao: PersonDao
) : PersonService {

    override fun getByName(name: String): Person {
        return personDao.findByName(name)
    }

//    @Autowired
//    fun setPersonDao(@Qualifier("complexPerson") personDao: PersonDao) {
//        this.personDao = personDao
//    }
}




### Person.kt
package org.example.springintro.data

class Person(val name: String)




### PersonDao.kt
package org.example.springintro.dao

import org.example.springintro.data.Person

interface PersonDao {

    fun findByName(name: String): Person
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



### PersonDaoComplex.kt
package org.example.springintro.dao

import org.example.springintro.data.Person
import org.springframework.stereotype.Service

@Service("complexPerson")
class PersonDaoComplex : PersonDao {

    override fun findByName(name: String): Person {
        return Person("complex")
    }
}
