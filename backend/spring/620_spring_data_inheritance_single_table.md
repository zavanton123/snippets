# Spring - Data, JPA inheritance - Single Table strategy (superclass and child classes share one table)



### resources/application.yml
server:
  port: 9999

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
    defer-datasource-initialization: true










### kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### kotlin/ru/zavanton/demo/runner/DataInitializer.kt
package ru.zavanton.demo.runner

import javax.persistence.EntityManager
import javax.persistence.PersistenceContext
import javax.transaction.Transactional
import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import ru.zavanton.demo.entity.Employee
import ru.zavanton.demo.entity.Student

@Component
class DataInitializer(
    @PersistenceContext
    val entityManager: EntityManager
) : CommandLineRunner {

    @Transactional
    override fun run(vararg args: String) {
        val employee = Employee(name = "Mike", company = "Sony")
        entityManager.persist(employee)

        val student = Student(name = "Tom", grade = 4.5)
        entityManager.persist(student)
    }
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class MyController {

    @GetMapping("")
    fun home(): String {
        return "ok"
    }
}










### kotlin/ru/zavanton/demo/entity/Student.kt
package ru.zavanton.demo.entity

import javax.persistence.DiscriminatorValue
import javax.persistence.Entity

@Entity
@DiscriminatorValue("student")
class Student(
    id: Long = 0L,
    name: String = "",
    var grade: Double = 0.0
) : Person(id, name)










### kotlin/ru/zavanton/demo/entity/Employee.kt
package ru.zavanton.demo.entity

import javax.persistence.DiscriminatorValue
import javax.persistence.Entity

@Entity
@DiscriminatorValue("employee")
class Employee(
    id: Long = 0L,
    name: String = "",
    var company: String = "",
) : Person(id, name)










### kotlin/ru/zavanton/demo/entity/Person.kt
package ru.zavanton.demo.entity

import javax.persistence.Column
import javax.persistence.DiscriminatorColumn
import javax.persistence.DiscriminatorType
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.Inheritance
import javax.persistence.InheritanceType

@Entity
@Inheritance(strategy = InheritanceType.SINGLE_TABLE)
@DiscriminatorColumn(
    name = "person_type",
    discriminatorType = DiscriminatorType.STRING
)
open class Person(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    open var id: Long = 0L,

    @Column(name = "full_name")
    open var name: String = ""
)
