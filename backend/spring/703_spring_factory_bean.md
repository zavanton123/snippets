# Spring - bean factory, AbstractFactoryBean, @Resource(name = "&someNameHere")



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










### kotlin/ru/zavanton/demo/config/ToolConfig.kt
package ru.zavanton.demo.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import ru.zavanton.demo.data.Tool
import ru.zavanton.demo.data.ToolFactory

@Configuration
class ToolConfig {

    // note: we have two beans with the same name 'tool'
    @Bean("tool")
    fun toolFactory(): ToolFactory {
        return ToolFactory(100L, 200L)
    }

    @Bean
    fun tool(): Tool {
        return toolFactory().`object`
    }
}










### kotlin/ru/zavanton/demo/data/Tool.kt
package ru.zavanton.demo.data

class Tool(
    var id: Long = 0L
)










### kotlin/ru/zavanton/demo/data/ToolFactory.kt
package ru.zavanton.demo.data

import org.springframework.beans.factory.config.AbstractFactoryBean

class ToolFactory(
    val factoryId: Long,
    val toolId: Long
) : AbstractFactoryBean<Tool>() {

    // note: the bean can be singleton or prototype
    init {
        isSingleton = false
    }

    override fun getObjectType(): Class<*> {
        return Tool::class.java
    }

    override fun createInstance(): Tool {
        return Tool(toolId)
    }
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import javax.annotation.Resource
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.data.ToolFactory

@RestController
class MyController {
    private val log = LoggerFactory.getLogger(MyController::class.java)

    // Note: &tool to access the factory bean
    @Resource(name = "&tool")
    lateinit var toolFactory: ToolFactory

    @GetMapping("")
    fun hello(): String {
        log.info("zavanton - toolfactory id: ${toolFactory.factoryId}")
        return "hello"
    }
}
