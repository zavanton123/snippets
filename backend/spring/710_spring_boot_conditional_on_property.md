# Spring - Boot, @EnableAutoConfiguration, @ConditionalOnProperty, etc.


### resources/application.yml
custom:
  enable-company: false

server:
  port: 3000










### kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### kotlin/ru/zavanton/demo/config/MyAutoConfig.kt
package ru.zavanton.demo.config

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import ru.zavanton.demo.data.Company

@Configuration
@ConditionalOnProperty(
    name = ["custom.enable-company"],
    havingValue = "true"
)
class MyAutoConfig {

    @Bean
    fun company(): Company {
        return Company(0L, "Google")
    }
}











### kotlin/ru/zavanton/demo/config/MyOtherConfig.kt
package ru.zavanton.demo.config

import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import ru.zavanton.demo.data.Company

@Configuration
@ConditionalOnProperty(
    name = ["custom.enable-company"],
    havingValue = "false"
)
class MyOtherConfig {

    @Bean
    fun company(): Company {
        return Company(1L, "Facebook")
    }
}









### kotlin/ru/zavanton/demo/data/Company.kt
package ru.zavanton.demo.data

class Company(
    var id: Long = 0L,
    var name: String = ""
)










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.data.Company

@RestController
class MyController(
    private val company: Company
) {
    private val log = LoggerFactory.getLogger(MyController::class.java)

    @GetMapping("")
    fun index(): String {
        log.info("zavanton - company: ${company.name}")
        return "index"
    }
}
