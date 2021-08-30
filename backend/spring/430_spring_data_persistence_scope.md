# Spring - Data, Transaction VS Extended PersistenceScope



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










### test/kotlin/ru/zavanton/demo/PersistenceContextTest.kt
package ru.zavanton.demo

import javax.persistence.TransactionRequiredException
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertDoesNotThrow
import org.junit.jupiter.api.assertThrows
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import ru.zavanton.demo.entity.User
import ru.zavanton.demo.exception.UserDoestNotExistException
import ru.zavanton.demo.service.ExtendedPersistenceContextService
import ru.zavanton.demo.service.TransactionPersistenceContextService

@SpringBootTest(classes = [App::class])
class PersistenceContextTest {

    @Autowired
    lateinit var transactionalService: TransactionPersistenceContextService

    @Autowired
    lateinit var extendedService: ExtendedPersistenceContextService

    @BeforeEach
    fun setup() {
        transactionalService.clearData()
        extendedService.clearData()
    }

    @Test
    fun `test transaction persistence context throws TransactionRequiredException`() {
        assertThrows<TransactionRequiredException> {
            val user = User(name = "James")
            transactionalService.saveWithoutTransaction(user)
        }
    }

    @Test
    fun `test extended persistence context does not throw exception`() {
        assertDoesNotThrow {
            val user = User(name = "James")
            val actual = extendedService.saveWithoutTransaction(user)
            assertThat(actual).isEqualTo(user)
        }
    }

    @Test
    fun `test transaction context`() {
        val user = User(name = "James")
        val (id, _) = transactionalService.saveWithTransaction(user)

        val user1 = transactionalService.fetchUser(id)
        val user2 = extendedService.fetchUser(id)
        assertThat(user1).isEqualTo(user2)
    }

    @Test
    fun `test extended context save without transaction`() {
        val user = User(name = "James")
        val (id, _) = extendedService.saveWithoutTransaction(user)

        assertThrows<UserDoestNotExistException> {
            extendedService.fetchUser(id)
        }

        assertThrows<UserDoestNotExistException> {
            transactionalService.fetchUser(id)
        }
    }

    @Test
    fun `test extended context save with transaction`() {
        val user = User(name = "James")
        val (id, _) = extendedService.saveWithTransaction(user)

        val user1 = transactionalService.fetchUser(id)
        assertThat(user1).isNotNull()

        val user2 = extendedService.fetchUser(id)
        assertThat(user2).isNotNull()
    }

}










### main/resources/application.yml
server:
  port: 9999

spring:
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










### main/kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### main/kotlin/ru/zavanton/demo/exception/UserDoestNotExistException.kt
package ru.zavanton.demo.exception

import java.lang.RuntimeException

class UserDoestNotExistException: RuntimeException()










### main/kotlin/ru/zavanton/demo/entity/User.kt
package ru.zavanton.demo.entity

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id

@Entity
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    val id: Long = 0L,
    val name: String = ""
)










### main/kotlin/ru/zavanton/demo/service/ExtendedPersistenceContextService.kt
package ru.zavanton.demo.service

import javax.persistence.EntityManager
import javax.persistence.PersistenceContext
import javax.persistence.PersistenceContextType
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import ru.zavanton.demo.entity.User
import ru.zavanton.demo.exception.UserDoestNotExistException

@Service
class ExtendedPersistenceContextService(
    @PersistenceContext(type = PersistenceContextType.EXTENDED)
    private val entityManager: EntityManager
) {

    @Transactional
    fun saveWithTransaction(user: User): User {
        entityManager.persist(user)
        return user
    }

    fun saveWithoutTransaction(user: User): User {
        entityManager.persist(user)
        return user
    }

    fun fetchUser(id: Long): User {
        return entityManager.find(User::class.java, id)
            ?: throw UserDoestNotExistException()
    }

    fun clearData() {
        entityManager.clear()
    }
}










### main/kotlin/ru/zavanton/demo/service/TransactionPersistenceContextService.kt
package ru.zavanton.demo.service

import javax.persistence.EntityManager
import javax.persistence.PersistenceContext
import javax.persistence.PersistenceContextType
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional
import ru.zavanton.demo.entity.User
import ru.zavanton.demo.exception.UserDoestNotExistException

@Service
class TransactionPersistenceContextService(
    @PersistenceContext(type = PersistenceContextType.TRANSACTION)
    private val entityManager: EntityManager
) {

    @Transactional
    fun saveWithTransaction(user: User): User {
        entityManager.persist(user)
        return user
    }

    fun saveWithoutTransaction(user: User): User {
        entityManager.persist(user)
        return user
    }

    fun fetchUser(id: Long): User {
        return entityManager.find(User::class.java, id)
            ?: throw UserDoestNotExistException()
    }

    fun clearData() {
        entityManager.clear()
    }
}
