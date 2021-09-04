# Spring - Error Handling (custom exceptions, RuntimeStatusException, @ResponseStatus, @ControllerAdvice, @ExceptionHandler, AccessDeniedHandled)

### test/kotlin/ru/zavanton/demo/AppTests.kt
package ru.zavanton.demo

import org.junit.jupiter.api.Test
import org.springframework.boot.test.context.SpringBootTest

@SpringBootTest
class AppTests {

	@Test
	fun contextLoads() {
	}

}










### main/resources/application.yml
server:
  port: 9999
  # some error handling setup
  error:
    whitelabel:
      enabled: true
    path: /error
    include-exception: false
    include-binding-errors: never
    include-stacktrace: never
    include-message: never










### main/resources/templates/access-denied.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Access Denied</title>
</head>
<body>
<h1>Access Denied Exception</h1>
</body>
</html>









### main/resources/templates/custom-error.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Custom Error</title>
</head>
<body>
<h1>Custom Error Page</h1>
</body>
</html>









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









### main/resources/templates/access-denied2.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Access Denied2</title>
</head>
<body>
<h1>Access Denied Exception2</h1>
</body>
</html>









### main/kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### main/kotlin/ru/zavanton/demo/config/SecurityConfig.kt
package ru.zavanton.demo.config

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.annotation.Bean
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.web.access.AccessDeniedHandler

@EnableWebSecurity
class SecurityConfig : WebSecurityConfigurerAdapter() {

    @Autowired
    lateinit var accessDeniedHandler: AccessDeniedHandler

    @Autowired
    fun configureGlobal(auth: AuthenticationManagerBuilder) {
        auth.inMemoryAuthentication()
            .passwordEncoder(encoder())
            .withUser("zavanton")
            .password(encoder().encode("1234"))
            .authorities("USER")
    }

    override fun configure(http: HttpSecurity) {
        http.authorizeRequests()
            .antMatchers("/error")
            .permitAll()
            .antMatchers("/")
            .hasAuthority("ADMIN")
            .antMatchers("/demo")
            .hasAuthority("ADMIN")
            .and()
            .exceptionHandling()
            // .accessDeniedPage("/no-access")
            .accessDeniedHandler(accessDeniedHandler)
            .and()
            .httpBasic()
    }

    @Bean
    fun encoder(): PasswordEncoder {
        return BCryptPasswordEncoder()
    }
}










### main/kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import org.springframework.web.server.ResponseStatusException
import ru.zavanton.demo.exceptions.CustomException

@RestController
class MyController {

    @GetMapping("/demo")
    fun demo(): String {
        return "demo"
    }

    @GetMapping("/custom")
    fun home(): String {
        throw CustomException()
    }

    @GetMapping("/more")
    fun more(): String {
        throw ResponseStatusException(
            HttpStatus.NOT_FOUND,
            "This is a custom message...",
            RuntimeException("my exception goes here...")
        )
    }
}










### main/kotlin/ru/zavanton/demo/controller/PageController.kt
package ru.zavanton.demo.controller

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping

@Controller
class PageController {

    @GetMapping("/")
    fun index(): String {
        return "index"
    }

    @GetMapping("/no-access")
    fun accessDenied(): String {
        return "access-denied"
    }

    @GetMapping("/no-access2")
    fun accessDenied2(): String {
        return "access-denied2"
    }

    @GetMapping("/error")
    fun customError(): String {
        return "custom-error"
    }
}










### main/kotlin/ru/zavanton/demo/exceptions/CustomAdvice.kt
package ru.zavanton.demo.exceptions

import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.ControllerAdvice
import org.springframework.web.bind.annotation.ExceptionHandler
import org.springframework.web.context.request.WebRequest
import org.springframework.web.server.ResponseStatusException
import org.springframework.web.servlet.mvc.method.annotation.ResponseEntityExceptionHandler

@ControllerAdvice
class CustomAdvice : ResponseEntityExceptionHandler() {

    @ExceptionHandler(ResponseStatusException::class)
    fun handle(
        exception: ResponseStatusException,
        request: WebRequest
    ): ResponseEntity<CustomBody> {
        return ResponseEntity(
            CustomBody(
                title = exception.localizedMessage,
                content = exception.reason ?: "default content here..."
            ),
            exception.status
        )
    }
}










### main/kotlin/ru/zavanton/demo/exceptions/CustomException.kt
package ru.zavanton.demo.exceptions

import java.lang.RuntimeException
import org.springframework.http.HttpStatus
import org.springframework.web.bind.annotation.ResponseStatus

@ResponseStatus(HttpStatus.NOT_FOUND)
class CustomException: RuntimeException() {
}










### main/kotlin/ru/zavanton/demo/exceptions/CustomBody.kt
package ru.zavanton.demo.exceptions

class CustomBody(
   var title: String = "",
   var content: String = ""
)










### main/kotlin/ru/zavanton/demo/exceptions/CustomAccessDeniedHandler.kt
package ru.zavanton.demo.exceptions

import javax.servlet.http.HttpServletRequest
import javax.servlet.http.HttpServletResponse
import org.springframework.security.access.AccessDeniedException
import org.springframework.security.web.access.AccessDeniedHandler
import org.springframework.stereotype.Component

@Component
class CustomAccessDeniedHandler: AccessDeniedHandler {

    override fun handle(
        request: HttpServletRequest,
        response: HttpServletResponse,
        accessDeniedException: AccessDeniedException
    ) {
        response.sendRedirect("no-access2")
    }
}
