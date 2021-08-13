# Java Spring - Multiple properties files



### resources/application-us.properties
custom.user=zavanton_us




### resources/application.properties
custom.user=zavanton



### resources/application-ru.properties
custom.user=zavanton_ru



### resources/application.yml
server:
  port: 6767

custom:
  password: 1234
spring:
  profiles:
    active: ru











### kotlin/ru/zavanton/value/App.kt
package ru.zavanton.value

import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import ru.zavanton.value.service.CustomService

@SpringBootApplication
class ValueDemoApplication

private val log = LoggerFactory.getLogger("main")

fun main(args: Array<String>) {
    val context = runApplication<ValueDemoApplication>(*args)

    val customService = context.getBean(CustomService::class.java)

    log.info("zavanton - username: ${customService.fetchCustomData()}")
}










### kotlin/ru/zavanton/value/service/CustomService.kt
package ru.zavanton.value.service

import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Service

@Service
class CustomService(
    @Value("\${custom.user}")
    private val username: String,

    @Value("\${custom.password}")
    private val password: String
) {

    fun fetchCustomData(): String {
        return "username: $username, password: $password"
    }
}
