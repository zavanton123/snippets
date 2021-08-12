# Java Spring - Using profiles



### resources/application.yml
server:
  port: 7878

#spring:
#  profiles:
#    active: DE










### resources/templates/hello.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Hello</title>
</head>
<body>
<h1>Hello</h1>
<p th:text="${message}">hello</p>
</body>
</html>










### kotlin/ru/zavanton/profile/App.kt
package ru.zavanton.profile

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### kotlin/ru/zavanton/profile/controller/I18nController.kt
package ru.zavanton.profile.controller

import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.web.bind.annotation.GetMapping
import ru.zavanton.profile.service.HelloService

@Controller
class I18nController(
    @Qualifier("I18nService")
    private val helloService: HelloService
) {

    @GetMapping("/")
    fun home(model: Model): String {
        val greeting = helloService.greet()
        model.addAttribute("message", greeting)
        return "hello"
    }
}










### kotlin/ru/zavanton/profile/service/HelloService.kt
package ru.zavanton.profile.service

interface HelloService {

    fun greet(): String
}










### kotlin/ru/zavanton/profile/service/UsHelloServiceImpl.kt
package ru.zavanton.profile.service

import org.springframework.context.annotation.Primary
import org.springframework.context.annotation.Profile
import org.springframework.stereotype.Service

@Primary
@Profile("US", "default")
@Service("I18nService")
class UsHelloServiceImpl : HelloService {

    override fun greet(): String {
        return "Hello world"
    }
}










### kotlin/ru/zavanton/profile/service/RuHelloServiceImpl.kt
package ru.zavanton.profile.service

import org.springframework.context.annotation.Profile
import org.springframework.stereotype.Service

@Profile("RU")
@Service("I18nService")
class RuHelloServiceImpl : HelloService {

    override fun greet(): String {
        return "Привет мир!"
    }
}
