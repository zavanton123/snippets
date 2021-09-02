# Spring - Data, composite identifier, @Embeddable, @EmbeddedId



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
import ru.zavanton.demo.entity.OrderEntry
import ru.zavanton.demo.entity.OrderEntryPK

@Component
class DataInitializer(
    @PersistenceContext
    private val entityManager: EntityManager
) : CommandLineRunner {

    @Transactional
    override fun run(vararg args: String) {
        val pk = OrderEntryPK(orderId = 1L, productId = 100L)
        val order = OrderEntry(pk)
        entityManager.persist(order)
    }
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class MyController(
) {
    private val log = LoggerFactory.getLogger(MyController::class.java)

    @GetMapping("")
    fun home(): String {

        return "home"
    }
}










### kotlin/ru/zavanton/demo/entity/OrderEntryPK.kt
package ru.zavanton.demo.entity

import java.io.Serializable
import javax.persistence.Embeddable

@Embeddable
class OrderEntryPK(
    var orderId: Long = 0L,
    var productId: Long = 0L
) : Serializable {

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as OrderEntryPK

        if (orderId != other.orderId) return false
        if (productId != other.productId) return false

        return true
    }

    override fun hashCode(): Int {
        var result = orderId.hashCode()
        result = 31 * result + productId.hashCode()
        return result
    }
}










### kotlin/ru/zavanton/demo/entity/OrderEntry.kt
package ru.zavanton.demo.entity

import javax.persistence.EmbeddedId
import javax.persistence.Entity

@Entity
class OrderEntry(

    @EmbeddedId
    var orderEntryPK: OrderEntryPK
)
