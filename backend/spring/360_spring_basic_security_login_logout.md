# Spring - Security Basics (default user with password, custom login form, logout)






### resources/application.yml
server:
  port: 9999

spring:
#  # spring security config
#  security:
#    user:
#      name: zavanton
#      password: 1234
#      roles: ADMIN

  # jpa config
  datasource:
    driverClassName: org.h2.Driver
    password: admin
    url: jdbc:h2:mem:testdb
    username: admin
  h2:
    console:
      enabled: true
      path: /h2/
      settings:
        trace: false
        web-allow-others: false
  jpa:
    database-platform: org.hibernate.dialect.H2Dialect
    defer-datasource-initialization: true










### resources/templates/login.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Login</title>
</head>
<body>
<h1>Login</h1>

<div th:if="${param.error}">Invalid username or password</div>
<div th:if="${param.logout}">You have logged out!</div>

<form th:action="@{/doLogin}" method="post">
    <label>Username:</label>
    <br/>
    <input type="text" name="username"/>
    <br/>

    <label>Password:</label>
    <br/>
    <input type="password" name="password"/>
    <br/>

    <input type="submit" value="Login"/>
</form>

</body>
</html>









### resources/templates/index.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Home</title>
</head>
<body>
<h1>Home</h1>

<form th:action="@{/doLogout}" method="post">
    <input type="submit" value="Logout">
</form>

</body>
</html>










### resources/templates/delete_user.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Delete User</title>
</head>
<body>
<h1>Delete User</h1>
</body>
</html>









### kotlin/ru/zavanton/bond/App.kt
package ru.zavanton.bond

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### kotlin/ru/zavanton/bond/config/SecurityConfig.kt
package ru.zavanton.bond.config

import org.springframework.beans.factory.annotation.Autowired
import org.springframework.context.annotation.Bean
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.web.util.matcher.AntPathRequestMatcher

@EnableWebSecurity
class SecurityConfig : WebSecurityConfigurerAdapter() {

    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder()

    @Autowired
    fun configureGlobal(auth: AuthenticationManagerBuilder) {
        auth.inMemoryAuthentication()
            .passwordEncoder(passwordEncoder())
            .withUser("galina")
            .password(passwordEncoder().encode("1234"))
            .authorities("ADMIN")
    }

    override fun configure(http: HttpSecurity) {
        http.authorizeRequests()
            .antMatchers("/delete/**").hasAnyAuthority("ADMIN", "SUPER-ADMIN")
            .anyRequest().authenticated()
            .and()
            .formLogin()
            .permitAll()
            .loginPage("/login")
            .loginProcessingUrl("/doLogin")
            .and()
            .logout()
            .permitAll()
            .logoutRequestMatcher(AntPathRequestMatcher("/doLogout", "POST"))
            .and()
            .httpBasic()
    }
}










### kotlin/ru/zavanton/bond/controller/IndexController.kt
package ru.zavanton.bond.controller

import org.springframework.stereotype.Controller
import org.springframework.web.bind.annotation.GetMapping

@Controller
class IndexController {

    @GetMapping("")
    fun index(): String {
        return "index"
    }

    @GetMapping("/delete/user")
    fun delete(): String {
        return "delete_user"
    }

    @GetMapping("/login")
    fun login(): String {
        return "login"
    }
}
