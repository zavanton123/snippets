# Spring - injecting a collection if it has no suitable beans (@Autowired(required=false))



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










### kotlin/ru/zavanton/demo/data/Rating.kt
package ru.zavanton.demo.data

interface Rating {

    fun getRating(): Int
}











### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.data.Rating

@RestController
class MyController @Autowired(required = false) constructor(
    private var ratings: MutableList<Rating> = mutableListOf()
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
