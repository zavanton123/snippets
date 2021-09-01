# Spring - Data, @Embeddable, @Embedded, @AttributeOverrides, @AttributeOverride



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










### kotlin/ru/zavanton/demo/entity/ContactPerson.kt
package ru.zavanton.demo.entity

import javax.persistence.AttributeOverride
import javax.persistence.AttributeOverrides
import javax.persistence.Column
import javax.persistence.Embeddable

@Embeddable
@AttributeOverrides(
    AttributeOverride(name = "firstName", column = Column(name = "contact_person_first_name")),
    AttributeOverride(name = "lastName", column = Column(name = "contact_person_last_name")),
    AttributeOverride(name = "phone", column = Column(name = "contact_person_phone"))
)
data class ContactPerson(

    var firstName: String = "",

    var lastName: String = "",

    var phone: String = ""
)










### kotlin/ru/zavanton/demo/entity/Company.kt
package ru.zavanton.demo.entity

import javax.persistence.Embedded
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
data class Company(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,

    val title: String = "",

    val phone: String = "",

    @Embedded
    val contactPerson: ContactPerson
)
