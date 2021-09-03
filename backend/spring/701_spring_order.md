# Spring - @Order



### resources/application.yml
server:
  port: 9999










### kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### kotlin/ru/zavanton/demo/data/ExcellentRating.kt
package ru.zavanton.demo.data

import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component

@Component
@Order(1)
class ExcellentRating : Rating {

    override fun getRating(): Int = 5
}










### kotlin/ru/zavanton/demo/data/GoodRating.kt
package ru.zavanton.demo.data

import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component

@Component
@Order(2)
class GoodRating : Rating {

    override fun getRating(): Int = 4
}










### kotlin/ru/zavanton/demo/data/Rating.kt
package ru.zavanton.demo.data

interface Rating {

    fun getRating(): Int
}











### kotlin/ru/zavanton/demo/data/AverageRating.kt
package ru.zavanton.demo.data

import org.springframework.core.Ordered
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component

@Component
@Order(Ordered.LOWEST_PRECEDENCE)
class AverageRating : Rating {

    override fun getRating(): Int = 3
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.data.Rating

@RestController
class MyController(
    private val ratings: List<Rating>
) {

    private val log = LoggerFactory.getLogger(MyController::class.java)

    @GetMapping("")
    fun hello(): String {
        log.info("zavanton - ratings: ")
        ratings.forEach { rating ->
            log.info("zavanton - ${rating.getRating()}")
        }

        return "hello"
    }
}
