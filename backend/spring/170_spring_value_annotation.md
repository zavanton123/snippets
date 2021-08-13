# Java Spring @Value

### application.yml
```
custom:
    info:
        password: pass
    username: zavanton
server:
    port: 9999

```



### App.kt
package ru.zavanton.value

import org.slf4j.LoggerFactory
import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class ValueDemoApplication

private val log = LoggerFactory.getLogger("main")

fun main(args: Array<String>) {
val context = runApplication<ValueDemoApplication>(*args)

    val username = context.getBean("username")
    log.info("zavanton - username: $username")

    val password = context.getBean("password")
    log.info("zavanton - password: $password")
}












### CustomConfig.kt
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
