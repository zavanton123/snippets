# Spring - Data, Entity event listners, @PrePersist, @PreUpdate, @PreRemove; @EntityListeners



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










### kotlin/ru/zavanton/demo/DemoApplication.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class DemoApplication

fun main(args: Array<String>) {
	runApplication<DemoApplication>(*args)
}










### kotlin/ru/zavanton/demo/repository/PersonRepository.kt
package ru.zavanton.demo.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Person

@Repository
interface PersonRepository: JpaRepository<Person, Long> {
}










### kotlin/ru/zavanton/demo/listener/PersonEventListener.kt
package ru.zavanton.demo.listener

import javax.persistence.PostLoad
import javax.persistence.PostPersist
import javax.persistence.PostRemove
import javax.persistence.PostUpdate
import javax.persistence.PrePersist
import javax.persistence.PreRemove
import javax.persistence.PreUpdate
import org.slf4j.LoggerFactory
import ru.zavanton.demo.entity.Person

class PersonEventListener {

    private val log = LoggerFactory.getLogger(PersonEventListener::class.java)

    @PrePersist
    @PreUpdate
    @PreRemove
    fun beforeAnyUpdate(person: Person) {
        log.info("zavanton - beforeAnyUpdate: $person")
    }

    @PostLoad
    fun afterLoad(person: Person) {
        log.info("zavanton - afterLoad: $person")
    }

    @PostPersist
    @PostUpdate
    @PostRemove
    fun afterAnyUpdate(person : Person) {
        log.info("zavanton - afterAnyUpdate: $person")
    }
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.entity.Person
import ru.zavanton.demo.repository.PersonRepository

@RestController
class MyController(
    private val personRepository: PersonRepository
) {

    @PostMapping("/persons/create")
    fun demo(): String {
        val person = Person(name = "Jack")
        personRepository.save(person)
        return "demo"
    }
}










### kotlin/ru/zavanton/demo/entity/Person.kt
package ru.zavanton.demo.entity

import javax.persistence.Entity
import javax.persistence.EntityListeners
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.PostLoad
import javax.persistence.PostPersist
import javax.persistence.PostRemove
import javax.persistence.PostUpdate
import javax.persistence.PrePersist
import javax.persistence.PreRemove
import javax.persistence.PreUpdate
import org.slf4j.LoggerFactory
import ru.zavanton.demo.listener.PersonEventListener

@Entity
@EntityListeners(PersonEventListener::class)
data class Person(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,
    var name: String = ""
) {

    @Transient
    private val log = LoggerFactory.getLogger(Person::class.java)

    @PrePersist
    fun onPrePersist() {
        log.info("zavanton - onPrePersist")
    }

    @PostPersist
    fun onPostPersist() {
        log.info("zavanton - onPostPersist")
    }

    @PreUpdate
    @PreRemove
    @PostLoad
    @PostUpdate
    @PostRemove
    fun onAnyEvent() {
        log.info("zavanton - onAnyEvent")
    }
}
