# Spring - Spring Security Intro



### test/kotlin/com/shkolum/backend/AppTests.kt
package com.shkolum.backend

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTests {

	@Test
	fun contextLoads() {
	}

}










### main/resources/application.yml
```
server:
  port: 9999

#spring:
#  security:
#    user:
#      name: zavanton
#      password: 1234
```










### main/resources/templates/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Home</title>
</head>
<body>
<h1>Home</h1>
</body>
</html>









### main/kotlin/com/shkolum/backend/App.kt
package com.shkolum.backend

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class ShkolumApplication

fun main(args: Array<String>) {
	runApplication<ShkolumApplication>(*args)
}










### main/kotlin/com/shkolum/backend/config/SecurityConfig.kt
package com.shkolum.backend.config

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.annotation.Bean
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder

@EnableWebSecurity
class SecurityConfig : WebSecurityConfigurerAdapter() {

    @Autowired
    fun configureGlobal(auth: AuthenticationManagerBuilder) {
        auth.inMemoryAuthentication()
            .passwordEncoder(encoder())
            .withUser("zavanton")
            .password(encoder().encode("1234"))
            .roles("USER")
    }

    @Bean
    fun encoder(): PasswordEncoder {
        return BCryptPasswordEncoder()
    }
}










### main/kotlin/com/shkolum/backend/controller/IndexController.kt
package com.shkolum.backend.controller

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping

@Controller
class IndexController {

    @GetMapping("")
    fun index(): String {
        return "index"
    }
}
