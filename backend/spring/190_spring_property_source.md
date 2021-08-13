# Java Spring - @PropertySource and Environment



### resources/custom.properties
demo.temperature=36.6
demo.height=100










### resources/application.yml
server:
  port: 8987










### kotlin/ru/zavanton/value/App.kt
package ru.zavanton.value

import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class ValueDemoApplication

private val log = LoggerFactory.getLogger("main")

fun main(args: Array<String>) {
    val context = runApplication<ValueDemoApplication>(*args)

    val customData = context.getBean("customData")
    log.info("zavanton - customData: $customData")

    val path = context.getBean("path")
    log.info("zavanton - path: $path")
}










### kotlin/ru/zavanton/value/PropertySourceConfig.kt
package ru.zavanton.value

import org.springframework.beans.factory.annotation.Value
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.PropertySource
import org.springframework.core.env.Environment

// Note: using @PropertySource you can get properties from a
// custom property file custom.properties
@Configuration
@PropertySource("classpath:custom.properties")
class PropertySourceConfig(

    @Value("\${demo.temperature}")
    private val temperature: String,

    @Value("\${demo.height}")
    private val height: Int,

    // Note: can be used to get environment variables
    private val environment: Environment
) {

    @Bean("customData")
    fun provideData(): String {
        return "Temp: $temperature, height: $height"
    }

    @Bean
    fun path(): String {
        return environment.getProperty("PATH") ?: "no path"
    }
}
