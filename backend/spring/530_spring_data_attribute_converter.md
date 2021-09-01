# Spring - Data, JPA AttributeConverter, @Converter, @Convert



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
package ru.zavanton.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Person

@Repository
interface PersonRepository : JpaRepository<Person, Long> {
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.entity.FullName
import ru.zavanton.demo.entity.Person
import ru.zavanton.demo.repository.PersonRepository

@RestController
class MyController(
    private val personRepository: PersonRepository
) {

    @PostMapping("/persons/create")
    fun create(): String {
        val fullName = FullName("Mike", "Tyson")
        val person = Person(fullName = fullName)
        personRepository.save(person)
        return "ok"
    }
}










### kotlin/ru/zavanton/demo/entity/FullName.kt
package ru.zavanton.demo.entity

data class FullName(
    var firstName: String = "",
    var lastName: String = ""
)










### kotlin/ru/zavanton/demo/entity/Person.kt
package ru.zavanton.demo.entity

import javax.persistence.Convert
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import ru.zavanton.demo.convert.FullNameConverter

@Entity
data class Person(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,

    @Convert(converter = FullNameConverter::class)
    var fullName: FullName
)










### kotlin/ru/zavanton/demo/convert/FullNameConverter.kt
package ru.zavanton.demo.convert

import javax.persistence.AttributeConverter
import javax.persistence.Converter
import ru.zavanton.demo.entity.FullName

@Converter
class FullNameConverter : AttributeConverter<FullName, String> {

    companion object {
        private const val SEPARATOR = " "
    }

    override fun convertToDatabaseColumn(attribute: FullName): String {
        if (attribute.firstName.isEmpty() || attribute.lastName.isEmpty()) {
            throw RuntimeException("first and last names must not be empty!")
        }
        return "${attribute.firstName}$SEPARATOR${attribute.lastName}"
    }

    override fun convertToEntityAttribute(dbData: String): FullName {
        val (firstName, lastName) = dbData.split(SEPARATOR)
        if (firstName.isEmpty() || lastName.isEmpty()) {
            throw RuntimeException("first and last names must not be empty!")
        }
        return FullName(firstName, lastName)
    }
}
