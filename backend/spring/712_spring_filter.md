# Spring - How to create a custom filter? Filter, @Order, @FilterRegistrationBean



### resources/application.yml
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










### kotlin/ru/zavanton/demo/config/FilterConfig.kt
package ru.zavanton.demo.config

import org.slf4j.LoggerFactory
import org.springframework.boot.web.servlet.FilterRegistrationBean
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import ru.zavanton.demo.filter.CustomLoggingFilter

@Configuration
class FilterConfig {

    private val log = LoggerFactory.getLogger(FilterConfig::class.java)

    @Bean
    fun loggingFilter(): FilterRegistrationBean<CustomLoggingFilter> {
        log.info("zavanton - filter config is setup...")
        return FilterRegistrationBean<CustomLoggingFilter>()
            .also { bean ->
                bean.filter = CustomLoggingFilter()
                bean.urlPatterns = listOf("/filter-demo", "/filter-more")
                bean.order = 1
            }
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
        return "home"
    }

    @GetMapping("/filter-demo")
    fun filterDemo(): String {
        return "filter demo"
    }

    @GetMapping("/filter-more")
    fun moreFilter(): String {
        return "filter more"
    }
}










### kotlin/ru/zavanton/demo/filter/CustomTransactionFilter.kt
package ru.zavanton.demo.filter

import javax.servlet.Filter
import javax.servlet.FilterChain
import javax.servlet.ServletRequest
import javax.servlet.ServletResponse
import javax.servlet.http.HttpServletRequest
import org.slf4j.LoggerFactory
import org.springframework.core.annotation.Order
import org.springframework.stereotype.Component

@Component
@Order(2)
class CustomTransactionFilter : Filter {

    private val log = LoggerFactory.getLogger(CustomTransactionFilter::class.java)

    override fun doFilter(
        request: ServletRequest,
        response: ServletResponse,
        chain: FilterChain
    ) {
        val httpRequest = request as HttpServletRequest
        log.info("zavanton - start transaction request: ${httpRequest.requestURI}")
        chain.doFilter(request, response)
        log.info("zavanton - end transaction request: ${httpRequest.requestURI}")
    }
}










### kotlin/ru/zavanton/demo/filter/CustomLoggingFilter.kt
package ru.zavanton.demo.filter

import javax.servlet.Filter
import javax.servlet.FilterChain
import javax.servlet.ServletRequest
import javax.servlet.ServletResponse
import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Component

@Component
class CustomLoggingFilter : Filter {

    private val log = LoggerFactory.getLogger(CustomLoggingFilter::class.java)

    override fun doFilter(
        request: ServletRequest,
        response: ServletResponse,
        chain: FilterChain
    ) {
        val httpRequest = request as HttpServletRequest
        val httpResponse = response as HttpServletResponse
        log.info("zavanton - logging request: ${httpRequest.method} ${httpRequest.requestURI}")
        chain.doFilter(request, response)
        log.info("zavanton - logging response: ${httpResponse.contentType}")
    }
}
