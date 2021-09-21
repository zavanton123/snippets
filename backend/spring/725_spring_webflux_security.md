# Spring - Webflux and Security via JWT token (@EnableWebFlux, @EnableWebFluxSecurity, WebFluxConfigurer, ReactiveAuthenticationManager, ServerSecurityContextRepository)



### app/build.gradle.kts
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.4"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
}

group = "ru.zavanton.app"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

repositories {
	mavenCentral()
}

dependencies {
	// Kotlin
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlinx:kotlinx-coroutines-reactor")
	implementation("io.projectreactor.kotlin:reactor-kotlin-extensions")
    // Spring
	implementation("org.springframework.boot:spring-boot-starter-security")
	implementation("org.springframework.boot:spring-boot-starter-webflux")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
	testImplementation("org.springframework.security:spring-security-test")
    // Json Web Token
	implementation("io.jsonwebtoken:jjwt-api:0.11.2")
	runtimeOnly("io.jsonwebtoken:jjwt-impl:0.11.2")
	runtimeOnly("io.jsonwebtoken:jjwt-jackson:0.11.2")
	// Jackson
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
    // Project reactor
	testImplementation("io.projectreactor:reactor-test")
}

tasks.withType<KotlinCompile> {
	kotlinOptions {
		freeCompilerArgs = listOf("-Xjsr305=strict")
		jvmTarget = "1.8"
	}
}

tasks.withType<Test> {
	useJUnitPlatform()
}









### app/src/main/resources/application.properties
server.port=9999

springbootwebfluxjjwt.password.encoder.secret=mysecret
springbootwebfluxjjwt.password.encoder.iteration=33
springbootwebfluxjjwt.password.encoder.keylength=256










### app/src/main/kotlin/ru/zavanton/app/demo/AuthApp.kt
package ru.zavanton.app.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class AuthApp

fun main(args: Array<String>) {
	runApplication<AuthApp>(*args)
}










### app/src/main/kotlin/ru/zavanton/app/demo/util/JwtHelper.kt
package ru.zavanton.app.demo.util

import io.jsonwebtoken.Claims
import io.jsonwebtoken.Jwts
import io.jsonwebtoken.security.Keys
import java.util.Date
import org.springframework.stereotype.Component
import ru.zavanton.app.demo.data.User
import ru.zavanton.app.demo.data.UserAuthority

@Component
class JwtHelper {

    private companion object {
        // 1 week in millisec
        const val EXPIRATION: Long = 1000 * 60 * 60 * 24 * 7
        const val SECRET =
            "this-is-token-secretthis-is-token-secretthis-is-token-secretthis-is-token-secretthis-is-token-secretthis-is-token-secretthis-is-token-secret"
        const val AUTHORITIES_KEY = "authorities"
    }

    fun parseClaims(token: String): Claims {
        return Jwts.parserBuilder()
            .setSigningKey(SECRET.toByteArray())
            .build()
            .parseClaimsJws(token)
            .body
    }

    fun parseUsername(token: String): String {
        return parseClaims(token)
            .subject
    }

    fun parseExpiration(token: String): Date {
        return parseClaims(token)
            .expiration
    }

    fun isExpired(token: String): Boolean {
        return parseExpiration(token).before(Date())
    }

    fun generateToken(user: User): String {
        return Jwts.builder()
            .setClaims(mapOf(AUTHORITIES_KEY to user.authorities.map(UserAuthority::name)))
            .setSubject(user.username)
            .setIssuedAt(Date())
            .setExpiration(Date(System.currentTimeMillis() + EXPIRATION))
            .signWith(Keys.hmacShaKeyFor(SECRET.toByteArray()))
            .compact()
    }

    fun validate(token: String): Boolean {
        return !isExpired(token)
    }

    fun parseAuthorities(token: String): List<UserAuthority> {
        return (parseClaims(token).get(AUTHORITIES_KEY, List::class.java) as List<String>)
            .map {
                UserAuthority.valueOf(it)
            }
    }
}










### app/src/main/kotlin/ru/zavanton/app/demo/data/User.kt
package ru.zavanton.app.demo.data

class User(
    var id: Long = 0L,
    var username: String = "",
    var password: String = "",
    var enabled: Boolean = false,
    val authorities: MutableList<UserAuthority> = mutableListOf(),
)







### app/src/main/kotlin/ru/zavanton/app/demo/data/UserAuthority.kt
package ru.zavanton.app.demo.data

enum class UserAuthority {
    USER,
    ADMIN,
}







### app/src/main/kotlin/ru/zavanton/app/demo/runner/MyRunner.kt
package ru.zavanton.app.demo.runner

import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import ru.zavanton.app.demo.data.User
import ru.zavanton.app.demo.data.UserAuthority.ADMIN
import ru.zavanton.app.demo.data.UserAuthority.USER
import ru.zavanton.app.demo.service.UserService

@Component
class MyRunner(
    private val userService: UserService,
) : CommandLineRunner {

    override fun run(vararg args: String) {
        val admin = User(
            id = 0L,
            username = "zavanton",
            password = "1234",
            enabled = true,
            authorities = mutableListOf(ADMIN)
        )
        val user = User(
            id = 1L,
            username = "james",
            password = "1234",
            enabled = true,
            authorities = mutableListOf(USER)
        )
        userService.save(admin)
        userService.save(user)
    }
}










### app/src/main/kotlin/ru/zavanton/app/demo/controller/MyController.kt
package ru.zavanton.app.demo.controller

import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.security.access.prepost.PreAuthorize
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.PostMapping
import org.springframework.web.bind.annotation.RequestBody
import org.springframework.web.bind.annotation.RestController
import reactor.core.publisher.Mono
import ru.zavanton.app.demo.controller.request.LoginRequest
import ru.zavanton.app.demo.controller.response.LoginResponse
import ru.zavanton.app.demo.service.UserService
import ru.zavanton.app.demo.util.JwtHelper

@RestController
class MyController(
    private val userService: UserService,
    private val passwordEncoder: PasswordEncoder,
    private val jwtHelper: JwtHelper,
) {

    @GetMapping("/about")
    fun about(): Mono<String> {
        return Mono.just("hello world")
    }

    @PostMapping("/login")
    fun login(
        @RequestBody request: LoginRequest,
    ): Mono<ResponseEntity<LoginResponse>> {
        return userService.findUser(request.username)
            .filter { user ->
                user.password == passwordEncoder.encode(request.password)
            }
            .map { user ->
                ResponseEntity.ok(LoginResponse(jwtHelper.generateToken(user)))
            }
            .switchIfEmpty(
                Mono.just(
                    ResponseEntity
                        .status(HttpStatus.UNAUTHORIZED)
                        .build()
                )
            )
    }

    @GetMapping("/user-data")
    fun privateData(): Mono<String> {
        return Mono.just("This is private data")
    }

    @GetMapping("/admin/data")
    fun adminData(): Mono<String> {
        return Mono.just("This is admin data")
    }

    @GetMapping("/protected")
    @PreAuthorize("hasAuthority('ADMIN')")
    fun dataForAdmin(): Mono<String> {
        return Mono.just("This is data for admin")
    }
}










### app/src/main/kotlin/ru/zavanton/app/demo/controller/request/LoginRequest.kt
package ru.zavanton.app.demo.controller.request

class LoginRequest(
    var username: String = "",
    var password: String = "",
)










### app/src/main/kotlin/ru/zavanton/app/demo/controller/response/LoginResponse.kt
package ru.zavanton.app.demo.controller.response

class LoginResponse(
    var token: String = "",
)










### app/src/main/kotlin/ru/zavanton/app/demo/security/PBKDF2Encoder.kt
package ru.zavanton.app.demo.security

import org.springframework.security.crypto.password.PasswordEncoder
import javax.crypto.SecretKeyFactory
import javax.crypto.spec.PBEKeySpec
import java.security.NoSuchAlgorithmException
import java.lang.RuntimeException
import java.security.spec.InvalidKeySpecException
import java.util.Base64
import org.springframework.beans.factory.annotation.Value
import org.springframework.stereotype.Component

@Component
class PBKDF2Encoder : PasswordEncoder {
    @Value("\${springbootwebfluxjjwt.password.encoder.secret}")
    private val secret: String? = null

    @Value("\${springbootwebfluxjjwt.password.encoder.iteration}")
    private val iteration: Int? = null

    @Value("\${springbootwebfluxjjwt.password.encoder.keylength}")
    private val keylength: Int? = null

    override fun encode(cs: CharSequence): String {
        return try {
            val result = SecretKeyFactory.getInstance("PBKDF2WithHmacSHA512")
                .generateSecret(
                    PBEKeySpec(
                        cs.toString().toCharArray(),
                        secret!!.toByteArray(),
                        iteration!!,
                        keylength!!
                    )
                )
                .encoded
            Base64.getEncoder().encodeToString(result)
        } catch (ex: NoSuchAlgorithmException) {
            throw RuntimeException(ex)
        } catch (ex: InvalidKeySpecException) {
            throw RuntimeException(ex)
        }
    }

    override fun matches(cs: CharSequence, string: String): Boolean {
        return encode(cs) == string
    }
}









### app/src/main/kotlin/ru/zavanton/app/demo/security/AuthAppSecurity.kt
package ru.zavanton.app.demo.security

import org.springframework.context.annotation.Bean
import org.springframework.http.HttpMethod
import org.springframework.security.config.annotation.method.configuration.EnableReactiveMethodSecurity
import org.springframework.security.config.annotation.web.reactive.EnableWebFluxSecurity
import org.springframework.security.config.web.server.ServerHttpSecurity
import org.springframework.security.web.server.SecurityWebFilterChain

@EnableWebFluxSecurity
@EnableReactiveMethodSecurity
class AuthAppSecurity(
    private val authenticationManager: MyAuthenticationManager,
    private val securityContextRepository: MySecurityContextRepository,
) {

    @Bean
    fun securityWebFilterChain(http: ServerHttpSecurity): SecurityWebFilterChain {
        http.formLogin().disable()
        http.csrf().disable()
        http.logout().disable()
        http.httpBasic().disable()

        http.authenticationManager(authenticationManager)
        http.securityContextRepository(securityContextRepository)

        http.authorizeExchange()
            .pathMatchers(HttpMethod.OPTIONS).permitAll()
            .pathMatchers("/login").permitAll()
            .pathMatchers("/admin/**").hasAuthority("ADMIN")
            .anyExchange().authenticated()
        return http.build()
    }
}










### app/src/main/kotlin/ru/zavanton/app/demo/security/CorsFilter.kt
package ru.zavanton.app.demo.security

import org.springframework.context.annotation.Configuration
import org.springframework.web.reactive.config.CorsRegistry
import org.springframework.web.reactive.config.EnableWebFlux
import org.springframework.web.reactive.config.WebFluxConfigurer

@Configuration
@EnableWebFlux
class CorsFilter : WebFluxConfigurer {

    override fun addCorsMappings(registry: CorsRegistry) {
        registry.addMapping("/**")
            .allowedOrigins("*")
            .allowedMethods("*")
            .allowedHeaders("*")
    }
}










### app/src/main/kotlin/ru/zavanton/app/demo/security/MyAuthenticationManager.kt
package ru.zavanton.app.demo.security

import org.springframework.security.authentication.ReactiveAuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.Authentication
import org.springframework.security.core.authority.SimpleGrantedAuthority
import org.springframework.stereotype.Component
import reactor.core.publisher.Mono
import ru.zavanton.app.demo.util.JwtHelper

@Component
class MyAuthenticationManager(
    private val jwtHelper: JwtHelper,
) : ReactiveAuthenticationManager {

    override fun authenticate(authentication: Authentication): Mono<Authentication> {
        return Mono.just(authentication.credentials.toString())
            .filter { jwt -> jwtHelper.validate(jwt) }
            .switchIfEmpty(Mono.empty())
            .map { jwt ->
                val authorities = jwtHelper.parseAuthorities(jwt)
                    .map { authority -> SimpleGrantedAuthority(authority.name) }
                UsernamePasswordAuthenticationToken(
                    jwtHelper.parseUsername(jwt),
                    null,
                    authorities
                )
            }
    }
}










### app/src/main/kotlin/ru/zavanton/app/demo/security/MySecurityContextRepository.kt
package ru.zavanton.app.demo.security

import org.springframework.http.HttpHeaders
import org.springframework.security.authentication.ReactiveAuthenticationManager
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken
import org.springframework.security.core.context.SecurityContext
import org.springframework.security.core.context.SecurityContextImpl
import org.springframework.security.web.server.context.ServerSecurityContextRepository
import org.springframework.stereotype.Component
import org.springframework.web.server.ServerWebExchange
import reactor.core.publisher.Mono

@Component
class MySecurityContextRepository(
    private val authenticationManager: ReactiveAuthenticationManager,
) : ServerSecurityContextRepository {

    private companion object {
        const val AUTHORIZATION_HEADER_PREFIX = "Bearer "
    }

    override fun save(
        exchange: ServerWebExchange,
        context: SecurityContext
    ): Mono<Void> {
        throw UnsupportedOperationException("This operation is not supported")
    }

    override fun load(exchange: ServerWebExchange): Mono<SecurityContext> {
        return Mono.justOrEmpty(exchange.request.headers.getFirst(HttpHeaders.AUTHORIZATION))
            .filter { authHeader ->
                authHeader.startsWith(AUTHORIZATION_HEADER_PREFIX)
            }
            .flatMap { authHeader ->
                val jwtToken = authHeader.substring(AUTHORIZATION_HEADER_PREFIX.length)
                val authToken = UsernamePasswordAuthenticationToken(jwtToken, jwtToken)
                authenticationManager.authenticate(authToken)
            }
            .map { authentication ->
                SecurityContextImpl(authentication)
            }
    }
}










### app/src/main/kotlin/ru/zavanton/app/demo/service/UserService.kt
package ru.zavanton.app.demo.service

import org.springframework.security.core.userdetails.UsernameNotFoundException
import org.springframework.security.crypto.password.PasswordEncoder
import org.springframework.stereotype.Service
import reactor.core.publisher.Mono
import ru.zavanton.app.demo.data.User

@Service
class UserService(
    private val passwordEncoder: PasswordEncoder,
) {

    // users should be persisted to DB
    var users = mutableListOf<User>()

    fun save(user: User): User {
        user.password = passwordEncoder.encode(user.password)
        users.add(user)
        return user
    }

    fun findUser(username: String): Mono<User> {
        val user = users.find {
            it.username == username
        } ?: throw UsernameNotFoundException("Not Found")
        return Mono.just(user)
    }

//    fun findByUsername(username: String): Mono<UserDetails> {
//        val user = users.find {
//            it.username == username
//        } ?: throw UsernameNotFoundException("Not Found")
//
//        return Mono.just(
//            SecurityUser(
//                user.username,
//                user.password,
//                user.enabled,
//                true,
//                true,
//                true,
//                user.authorities.map { userAuthority ->
//                    SimpleGrantedAuthority(userAuthority.name)
//                }
//            )
//        )
//    }
}









