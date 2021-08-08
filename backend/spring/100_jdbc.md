# Spring and JDBC

### build.gradle
plugins {
	id 'org.springframework.boot' version '2.5.3'
	id 'io.spring.dependency-management' version '1.0.11.RELEASE'
	id 'java'
}

group = 'ru.zavanton.demo'
version = '0.0.1-SNAPSHOT'
sourceCompatibility = '1.8'

repositories {
	mavenCentral()
}

dependencies {
	implementation group: 'mysql', name: 'mysql-connector-java', version: '8.0.25'
	implementation group: 'org.springframework', name: 'spring-jdbc', version: '5.3.9'
	implementation 'org.springframework.boot:spring-boot-starter-web'
	testImplementation 'org.springframework.boot:spring-boot-starter-test'
}

test {
	useJUnitPlatform()
}



### App.java
package ru.zavanton.demo.mydemo;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

import javax.sql.DataSource;


@SpringBootApplication
public class App {

    public static void main(String[] args) {
        SpringApplication.run(App.class, args);
    }

    @Bean
    public DataSource dataSource() {
        DriverManagerDataSource dataSource = new DriverManagerDataSource();
        dataSource.setDriverClassName("com.mysql.jdbc.Driver");
        dataSource.setUrl("jdbc:mysql://localhost:3306/custom");
        dataSource.setUsername("zavanton");
        dataSource.setPassword("some-pass-here");
        return dataSource;
    }

}





### CustomController.java
package ru.zavanton.demo.mydemo.controllers;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.zavanton.demo.mydemo.dao.IStudentDao;
import ru.zavanton.demo.mydemo.data.Student;

@RestController
public class CustomController {
    private IStudentDao dao;

    public CustomController(IStudentDao dao) {
        this.dao = dao;
    }

    @RequestMapping("/")
    public String home() {
        Student studentOne = dao.getById(1);
        System.out.println("studentOne: " + studentOne);

        for (Student student : dao.getAll()) {
            System.out.println(student);
        }

        System.out.println("Count: " + dao.count());
        return "home";
    }
}



### Student.kt
package ru.zavanton.demo.mydemo.data

data class Student(var name: String)




### StudentDao.java
package ru.zavanton.demo.mydemo.dao;

import org.springframework.jdbc.core.JdbcOperations;
import org.springframework.stereotype.Repository;
import ru.zavanton.demo.mydemo.data.Student;
import ru.zavanton.demo.mydemo.mapper.StudentMapper;

import java.util.List;

@Repository
public class StudentDao implements IStudentDao {
    private JdbcOperations jdbc;

    public StudentDao(JdbcOperations jdbc) {
        this.jdbc = jdbc;
    }

    @Override
    public int count() {
        return jdbc.queryForObject("select count(*) from student", Integer.class);
    }

    @Override
    public Student getById(int id) {
        return jdbc.queryForObject("select * from student where id = ?",
                new Object[]{id},
                new StudentMapper()
        );
    }

    @Override
    public List<Student> getAll() {
        return jdbc.queryForList("select * from student", Student.class);
    }
}




### StudentMapper.java
package ru.zavanton.demo.mydemo.mapper;

import org.springframework.jdbc.core.RowMapper;
import ru.zavanton.demo.mydemo.data.Student;

import java.sql.ResultSet;
import java.sql.SQLException;


public class StudentMapper implements RowMapper<Student> {

    @Override
    public Student mapRow(ResultSet resultSet, int rowNum) throws SQLException {
        String name = resultSet.getString("name");
        return new Student(name);
    }
}

