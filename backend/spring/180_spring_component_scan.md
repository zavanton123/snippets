# Java Spring - @ComponentScan (base package)


### resources/application.yml
custom:
    info:
        password: pass
    username: zavanton
server:
    port: 8987










### kotlin/ru/zavanton/value/CustomConfig.kt
package ru.zavanton.value

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class CustomConfig {

    @Bean("username")
    fun getUsername(
        @Value("\${custom.username}")
        username: String
    ): String = username

    @Bean
    fun password(
        @Value("\${custom.info.password}")
        password: String
    ) = password
}










### kotlin/com/evolunta/demo/App.kt
package com.evolunta.demo

import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.context.annotation.ComponentScan

@SpringBootApplication
@ComponentScan(basePackages = ["ru.zavanton.value", "com.evolunta.demo"])
class ValueDemoApplication

private val log = LoggerFactory.getLogger("main")

fun main(args: Array<String>) {
    val context = runApplication<ValueDemoApplication>(*args)

    val username = context.getBean("username")
    log.info("zavanton - username: $username")

    val password = context.getBean("password")
    log.info("zavanton - password: $password")
}
