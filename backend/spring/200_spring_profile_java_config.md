# Java Spring - @Profile with java configuration


### resources/application.yml
server:
  port: 8987

spring:
  profiles:
    active: RU










### kotlin/ru/zavanton/value/App.kt
package ru.zavanton.value

import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import ru.zavanton.value.greeting.Greeting

@SpringBootApplication
class ValueDemoApplication

private val log = LoggerFactory.getLogger("main")

fun main(args: Array<String>) {
    val context = runApplication<ValueDemoApplication>(*args)

    val greeting = context.getBean(Greeting::class.java)

    log.info("zavanton - greeting: ${greeting.greet()}")
}










### kotlin/ru/zavanton/value/config/GreetingConfig.kt
package ru.zavanton.value.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.Profile
import ru.zavanton.value.greeting.Greeting
import ru.zavanton.value.greeting.RuGreetingImpl
import ru.zavanton.value.greeting.UsGreetingImpl

@Configuration
class GreetingConfig {

    @Bean
    @Profile("RU")
    fun provideRuGreeting(): Greeting {
        return RuGreetingImpl()
    }

    @Bean
    @Profile("US", "default")
    fun provideUsGreeting(): Greeting {
        return UsGreetingImpl()
    }
}










### kotlin/ru/zavanton/value/greeting/Greeting.kt
package ru.zavanton.value.greeting

interface Greeting {

    fun greet(): String
}










### kotlin/ru/zavanton/value/greeting/RuGreetingImpl.kt
package ru.zavanton.value.greeting

class RuGreetingImpl : Greeting {

    override fun greet(): String {

       return "Привет мир"
    }
}










### kotlin/ru/zavanton/value/greeting/UsGreetingImpl.kt
package ru.zavanton.value.greeting

class UsGreetingImpl : Greeting {

    override fun greet(): String {
        return "Hello world"
    }
}
