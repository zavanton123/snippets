# Spring - Security (custom login form, registration to db, remember me)




### resources/schema.sql
create table if not exists persistent_logins (
    username varchar(100) not null,
    series varchar(64) primary key,
    token varchar(64) not null,
    last_used timestamp not null
    );










### resources/application.yml
server:
  port: 9999

spring:
  datasource:
    driverClassName: com.mysql.cj.jdbc.Driver
    password: 21665mylife
    url: jdbc:mysql://localhost:3306/demo_security?serverTimezone=UTC
    username: zavanton
  jpa:
    database-platform: org.hibernate.dialect.MySQL5InnoDBDialect
    defer-datasource-initialization: true
    show-sql: true
    hibernate:
      ddl-auto: create-drop










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

    <div>
        <label>Remember me</label>
        <input type="checkbox" name="remember" value="true"/>
    </div>

    <input type="submit" value="Login"/>
</form>

<a th:href="@{/signup}">Sign up</a>

</body>
</html>









### resources/templates/users.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>All Users</title>
</head>
<body>
<h1>All Users</h1>
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










### resources/templates/about.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>About Us</title>
</head>
<body>
<h1>About Us</h1>
</body>
</html>









### resources/templates/signup.html
<!DOCTYPE html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<head>
    <meta charset="UTF-8">
    <title>Sign UP</title>
</head>
<body>
<h1>Sign Up</h1>

<form th:object="${user}" th:action="@{/user/register}" method="post">

    <div th:if="${#fields.hasErrors('global')}">Password and confirmed password must match!</div>

    <label>Email:</label>
    <br/>
    <input type="text" th:field="*{email}"/>
    <br/>
    <p th:if="${#fields.hasErrors('email')}">Invalid Email</p>

    <label>Password:</label>
    <br/>
    <input type="password" th:field="*{password}"/>
    <br/>
    <p th:if="${#fields.hasErrors('password')}">Invalid password</p>

    <label>Confirm password:</label>
    <br/>
    <input type="password" th:field="*{confirmedPassword}"/>
    <br/>
    <p th:if="${#fields.hasErrors('confirmedPassword')}">Invalid confirmed password</p>

    <input type="submit" value="Sign Up"/>
</form>

</body>
</html>










### resources/templates/admin.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin</title>
</head>
<body>
<h1>Admin</h1>
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










### kotlin/ru/zavanton/bond/repository/UserRepository.kt
package ru.zavanton.bond.repository

import java.util.Optional
import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.bond.data.User

@Repository
interface UserRepository : JpaRepository<User, Long> {

    fun findByEmail(email: String): Optional<User>
}










### kotlin/ru/zavanton/bond/validation/PasswordMatches.kt
package ru.zavanton.bond.validation

import javax.validation.Constraint
import javax.validation.Payload
import kotlin.reflect.KClass

@Target(AnnotationTarget.CLASS, AnnotationTarget.ANNOTATION_CLASS)
@Retention(AnnotationRetention.RUNTIME)
@Constraint(validatedBy = [PasswordMatchesValidator::class])
annotation class PasswordMatches(
    val message: String = "Passwords do not match",
    val groups: Array<KClass<*>> = [],
    val payload: Array<KClass<out Payload>> = []
)










### kotlin/ru/zavanton/bond/validation/PasswordMatchesValidator.kt
package ru.zavanton.bond.validation

import javax.validation.ConstraintValidator
import javax.validation.ConstraintValidatorContext
import ru.zavanton.bond.data.User

class PasswordMatchesValidator : ConstraintValidator<PasswordMatches, Any> {

    override fun isValid(value: Any, context: ConstraintValidatorContext): Boolean {
        if (value is User) {
            val user: User = value
            return user.password == user.confirmedPassword
        }
        return false
    }
}










### kotlin/ru/zavanton/bond/config/SecurityConfig.kt
package ru.zavanton.bond.config

import javax.sql.DataSource
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.context.annotation.Bean
import org.springframework.core.io.ClassPathResource
import org.springframework.jdbc.datasource.init.DataSourceInitializer
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.security.web.authentication.rememberme.JdbcTokenRepositoryImpl
import org.springframework.security.web.authentication.rememberme.PersistentTokenRepository
import org.springframework.security.web.util.matcher.AntPathRequestMatcher

@EnableWebSecurity
class SecurityConfig(
    private val userDetailsService: UserDetailsService,
    private val dataSource: DataSource
) : WebSecurityConfigurerAdapter() {

    @Autowired
    fun configureGlobal(auth: AuthenticationManagerBuilder) {
        auth.userDetailsService(userDetailsService)
            .passwordEncoder(passwordEncoder())
    }

    override fun configure(http: HttpSecurity) {
        http.authorizeRequests()
            .antMatchers("/delete/**")
            .hasAnyAuthority("ADMIN", "SUPER-ADMIN")
            .antMatchers("/signup", "/user/register", "/about")
            .permitAll()
            .antMatchers("/admin")
            .hasAuthority("ADMIN")
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
            .and()
            .rememberMe()
            .rememberMeCookieName("custom-remember")
            .key("some-key-to-validate-cookie")
            .rememberMeParameter("remember")
            .tokenValiditySeconds(60 * 60 * 24 * 7)
            .tokenRepository(persistentTokenRepository())
    }

    @Bean
    fun dataSourceInitializer(
        @Qualifier("dataSource") dataSource: DataSource
    ): DataSourceInitializer {
        val resourceDatabasePopulator = ResourceDatabasePopulator()
        resourceDatabasePopulator.addScript(ClassPathResource("/schema.sql"))
        val dataSourceInitializer = DataSourceInitializer()
        dataSourceInitializer.setDataSource(dataSource)
        dataSourceInitializer.setDatabasePopulator(resourceDatabasePopulator)
        return dataSourceInitializer
    }

    @Bean
    fun passwordEncoder(): PasswordEncoder = BCryptPasswordEncoder()

    @Bean
    fun persistentTokenRepository(): PersistentTokenRepository {
        val repository = JdbcTokenRepositoryImpl()
        repository.setDataSource(dataSource)
        return repository
    }
}










### kotlin/ru/zavanton/bond/config/DataConfig.kt
package ru.zavanton.bond.config

import javax.sql.DataSource
import org.springframework.beans.factory.annotation.Qualifier
import org.springframework.context.annotation.Bean
import org.springframework.jdbc.datasource.init.DataSourceInitializer
import org.springframework.jdbc.datasource.init.ResourceDatabasePopulator
import org.springframework.core.io.ClassPathResource

class DataConfig {
}









### kotlin/ru/zavanton/bond/data/User.kt
package ru.zavanton.bond.data

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.validation.constraints.Email
import javax.validation.constraints.NotEmpty
import ru.zavanton.bond.validation.PasswordMatches

@Entity
@PasswordMatches
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,

    @get:Email
    var email: String = "",

    @get:NotEmpty(message = "password is required")
    var password: String = "",

    @field:Transient
    @get:NotEmpty(message = "password confirmation is required")
    var confirmedPassword: String = ""
)










### kotlin/ru/zavanton/bond/controller/MyController.kt
package ru.zavanton.bond.controller

import javax.validation.Valid
import org.slf4j.LoggerFactory
import org.springframework.stereotype.Controller
import org.springframework.ui.Model
import org.springframework.validation.Errors
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ModelAttribute
import org.springframework.web.bind.annotation.PostMapping
import ru.zavanton.bond.data.User
import ru.zavanton.bond.service.UserService

@Controller
class MyController(
    private val userService: UserService
) {

    private val log = LoggerFactory.getLogger(MyController::class.java)

    @GetMapping("")
    fun index(): String {
        return "index"
    }

    @GetMapping("/users")
    fun allUsers(): String {
        val users = userService.fetchAllUsers()
        users.forEach {
            log.info("zavanton - user: $it")
        }
        return "users"
    }

    @GetMapping("/about")
    fun about(): String {
        log.info("zavanton - /about is accessed")
        return "about"
    }

    @GetMapping("/delete/user")
    fun delete(): String {
        return "delete_user"
    }

    @GetMapping("/login")
    fun login(): String {
        log.info("zavanton - login is accessed")
        return "login"
    }

    @GetMapping("/signup")
    fun signup(model: Model): String {
        val user = User()
        model.addAttribute("user", user)
        return "signup"
    }

    @PostMapping("/user/register")
    fun signup(
        @Valid @ModelAttribute("user") user: User,
        errors: Errors
    ): String {
        log.info("zavanton - errors: $errors")
        if (errors.hasErrors()) {
            return "signup"
        }
        userService.registerUser(user)
        return "redirect:/"
    }

    @GetMapping("/admin")
    fun admin(): String {
        return "admin"
    }
}










### kotlin/ru/zavanton/bond/exception/DuplicateEmailException.kt
package ru.zavanton.bond.exception

class DuplicateEmailException(msg: String = "") : RuntimeException(msg)










### kotlin/ru/zavanton/bond/service/UserServiceImpl.kt
package ru.zavanton.bond.service

import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import ru.zavanton.bond.data.User
import ru.zavanton.bond.exception.DuplicateEmailException
import ru.zavanton.bond.repository.UserRepository

@Service
class UserServiceImpl(
    private val userRepository: UserRepository,
    private val passwordEncoder: PasswordEncoder
) : UserService {

    override fun registerUser(user: User): User {
        if (isDuplicateEmail(user.email)) {
            throw DuplicateEmailException("The user with the email ${user.email} already exists!")
        } else {
            val plainTextPassword = user.password
            val encodedPassword = passwordEncoder.encode(plainTextPassword)
            user.password = encodedPassword
            user.confirmedPassword = encodedPassword
            return userRepository.save(user)
        }
    }

    override fun fetchAllUsers(): Set<User> {
        return userRepository.findAll().toSet()
    }

    private fun isDuplicateEmail(email: String): Boolean {
        val userOptional = userRepository.findByEmail(email)
        return userOptional.isPresent
    }
}










### kotlin/ru/zavanton/bond/service/UserService.kt
package ru.zavanton.bond.service

import ru.zavanton.bond.data.User

interface UserService {

    fun registerUser(user: User): User

    fun fetchAllUsers(): Set<User>
}










### kotlin/ru/zavanton/bond/service/CustomUserDetailsService.kt
package ru.zavanton.bond.service

import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.security.core.userdetails.User
import org.springframework.security.core.userdetails.UserDetails
import org.springframework.security.core.userdetails.UserDetailsService
import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.stereotype.Service
import ru.zavanton.bond.repository.UserRepository

@Service
class CustomUserDetailsService(
    private val userRepository: UserRepository
) : UserDetailsService {

    override fun loadUserByUsername(email: String): UserDetails {
        val userOptional = userRepository.findByEmail(email)
        if (userOptional.isPresent) {
            val user = userOptional.get()
            return User(
                user.email,
                user.password,
                true,
                true,
                true,
                true,
                listOf(SimpleGrantedAuthority("USER"))
            )
        } else {
            throw UsernameNotFoundException("User is not found")
        }
    }
}
