# Spring - Data, One to one relationships via join table (@JoinTable)



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










### kotlin/ru/zavanton/demo/repository/UserRepository.kt
package ru.zavanton.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.User

@Repository
interface UserRepository : JpaRepository<User, Long> {
}










### kotlin/ru/zavanton/demo/repository/AddressRepository.kt
package ru.zavanton.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Address

@Repository
interface AddressRepository : JpaRepository<Address, Long> {

    fun queryByCity(city: String): Address
}










### kotlin/ru/zavanton/demo/runner/DataInitializer.kt
package ru.zavanton.demo.runner

import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import ru.zavanton.demo.entity.Address
import ru.zavanton.demo.entity.User
import ru.zavanton.demo.repository.UserRepository

@Component
class DataInitializer(
    private val userRepository: UserRepository
) : CommandLineRunner {

    override fun run(vararg args: String) {
        val city = "Moscow"
        val address1 = Address(city = city)
        val user1 = User(fullName = "Mike Tyson")
        user1.address = address1
        userRepository.save(user1)
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










### kotlin/ru/zavanton/demo/entity/User.kt
package ru.zavanton.demo.entity

import javax.persistence.CascadeType
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.JoinTable
import javax.persistence.OneToOne
import javax.persistence.Table

@Entity
@Table(name = "users")
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,

    @Column(name = "full_name")
    var fullName: String = ""
) {
    @OneToOne(cascade = [CascadeType.ALL])
    @JoinTable(
        name = "user_address",
        joinColumns = [JoinColumn(name = "user_id", referencedColumnName = "id")],
        inverseJoinColumns = [JoinColumn(name = "address_id", referencedColumnName = "id")]
    )
    var address: Address? = null
        set(value) {
            field = value
            value?.user = this
        }
}










### kotlin/ru/zavanton/demo/entity/Address.kt
package ru.zavanton.demo.entity

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.OneToOne
import javax.persistence.Table

@Entity
@Table(name = "addresses")
data class Address(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,

    var city: String = ""

) {
    @OneToOne(mappedBy = "address")
    var user: User? = null
}
