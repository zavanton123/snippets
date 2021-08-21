# Spring - Actuator and defining a custom health indicator




### resources/application.properties
# app port
server.port=9999
info.lsapp.name=Learn Spring Application
info.lsapp.description=Learn Spring Application Developed With Spring Boot 2
# the default base-path is /actuator
management.endpoints.web.base-path=/monitoring
# the default is /info
management.endpoints.web.path-mapping.info=/information
# show details (including custom health indicators)
management.endpoint.health.show-details=always










### kotlin/com/evolunta/demo/App.kt
package com.evolunta.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### kotlin/com/evolunta/demo/controller/MyController.kt
package com.evolunta.demo.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class MyController {

    @GetMapping("/")
    fun home(): String {
        return "home"
    }
}










### kotlin/com/evolunta/demo/indicator/DbHealthIndicator.kt
package com.evolunta.demo.indicator

import org.springframework.boot.actuate.health.Health
import org.springframework.boot.actuate.health.HealthIndicator
import org.springframework.stereotype.Component

// This is a custom health indicator
@Component
class DbHealthIndicator : HealthIndicator {

    override fun health(): Health {
        return if (isDbUp()) {
            Health.up().build()
        } else {
            Health.down()
                .withDetail("Error Code", 503)
                .build()
        }
    }

    private fun isDbUp() = false
}
