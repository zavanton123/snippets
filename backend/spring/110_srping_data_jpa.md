# Spring Data JPA

### build.gradle
plugins {
	id 'org.springframework.boot' version '2.5.3'
	id 'io.spring.dependency-management' version '1.0.11.RELEASE'
	id 'java'
}

group = 'ru.zavanton'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '1.8'

repositories {
	mavenCentral()
}

dependencies {
	implementation 'org.springframework.boot:spring-boot-starter-data-jpa'
	implementation 'org.springframework.data:spring-data-jpa'
	implementation 'org.springframework.boot:spring-boot-starter-web'
	implementation 'junit:junit:4.13.1'
	runtimeOnly 'com.h2database:h2'
	testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
	useJUnitPlatform()
}




### application.yml
server:
  port: 8989
spring:
  datasource:
    driverClassName: org.h2.Driver
    password: admin
    url: jdbc:h2:mem:testdb
    username: admin
  h2:
    console:
      enabled: true
      path: /h2/
      settings:
        trace: false
        web-allow-others: false
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect




### App.java
package ru.zavanton.jpa;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;

@SpringBootApplication
@EnableJpaRepositories
public class App {

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }
}




### MyController.java
package ru.zavanton.jpa.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.zavanton.jpa.data.Employee;
import ru.zavanton.jpa.service.MyService;

import java.util.List;

@RestController
public class MyController {
    private MyService service;

    public MyController(MyService service) {
        this.service = service;
    }

    @RequestMapping("/")
    public String home() {
        System.out.println("FETCHING PAGE...");
        for (Employee employee : service.fetchPage()) {
            System.out.println("Employee: " + employee);
        }

        System.out.println("FETCHING SORTED...");
        List<Employee> employees = service.fetchSorted();
        for (Employee employee : employees) {
            System.out.println("Employee: " + employee);
        }

        System.out.println("FETCH BY NAME");
        Employee employee = service.fetchEmployee("Mike");
        System.out.println("Employee name: " + employee);
        return "home";
    }
}




### MyServiceImpl.java
package ru.zavanton.jpa.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import ru.zavanton.jpa.data.Employee;
import ru.zavanton.jpa.repository.EmployeeRepository;
import ru.zavanton.jpa.repository.SortingRepository;

import javax.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.List;

@Service
public class MyServiceImpl implements MyService {
    private final EmployeeRepository repository;
    private final SortingRepository sortedRepository;

    @Autowired
    public MyServiceImpl(
            EmployeeRepository repository,
            SortingRepository sortedRepository
    ) {
        this.repository = repository;
        this.sortedRepository = sortedRepository;
    }

    @PostConstruct
    public void generateEmployees() {
        if (repository.count() == 0) {
            System.out.println("generating new employees...");
            repository.save(new Employee("Mike", "Jackson", "Marketing"));
            repository.save(new Employee("James", "Bond", "IT"));
            repository.save(new Employee("Tom", "ONeil", "CEO"));
            repository.save(new Employee("Mike2", "Jackson", "Marketing"));
            repository.save(new Employee("James2", "Bond", "IT"));
            repository.save(new Employee("Tom2", "ONeil", "CEO"));
        }
    }

    @Override
    public Employee fetchEmployee(String firstName) {
        return repository.findByFirstName(firstName);
    }

    @Override
    public List<Employee> fetchSorted() {
        List<Employee> result = new ArrayList<>();
        sortedRepository.findAll(Sort.by(Sort.Direction.DESC, "firstName"))
                .forEach(result::add);
        return result;
    }

    @Override
    public List<Employee> fetchPage() {
        List<Employee> result = new ArrayList<>();
        sortedRepository.findAll(PageRequest.of(0, 5))
                .forEach(result::add);
        return result;
    }
}



### EmployeeRepository.java
package ru.zavanton.jpa.repository;

import org.springframework.data.repository.CrudRepository;
import ru.zavanton.jpa.data.Employee;

import java.util.List;

public interface EmployeeRepository extends CrudRepository<Employee, Long> {

    Employee findByFirstName(String firstName);

    List<Employee> findByLastName(String lastName);
}




### SortingRepository.java
package ru.zavanton.jpa.repository;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.stereotype.Repository;
import ru.zavanton.jpa.data.Employee;

@Repository
public interface SortingRepository extends PagingAndSortingRepository<Employee, Long> {
}




### Employee.java
package ru.zavanton.jpa.data;

import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.Id;

@Entity
public class Employee {

    @Id
    @GeneratedValue
    private Long id;

    private String firstName, lastName, description;

    public Employee() {
    }

    public Employee(String firstName, String lastName, String description) {
        this.firstName = firstName;
        this.lastName = lastName;
        this.description = description;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    @Override
    public String toString() {
        return "Employee{" +
                "id=" + id +
                ", firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", description='" + description + '\'' +
                '}';
    }
}





### EmployeeRepositoryTest.java
package ru.zavanton.jpa.repository;

import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.transaction.annotation.Propagation;
import org.springframework.transaction.annotation.Transactional;
import ru.zavanton.jpa.data.Employee;

import static org.assertj.core.api.Assertions.assertThat;

@RunWith(SpringRunner.class)
@DataJpaTest
@Transactional(propagation = Propagation.NOT_SUPPORTED)
class EmployeeRepositoryTest {

    @Autowired
    private TestEntityManager entityManager;

    @Autowired
    private EmployeeRepository repository;

    @Test
    @Transactional
    void findByFirstName() {
        this.entityManager.persist(new Employee("Mike", "Tyson", "Boxing"));
        Employee employee = repository.findByFirstName("Mike");
        assertThat(employee.getFirstName()).isEqualTo("Mike");
        assertThat(employee.getLastName()).isEqualTo("Tyson");
    }
}

