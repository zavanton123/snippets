# Spring - Data, JPA query, named query, native query, Criteria API query, collection value parameters (@NamedQuery)



### resources/application.yml
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










### kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### kotlin/ru/zavanton/demo/runner/DataInitializer.kt
package ru.zavanton.demo.runner

import javax.persistence.EntityManager
import javax.persistence.PersistenceContext
import javax.persistence.Query
import javax.persistence.TypedQuery
import javax.transaction.Transactional
import org.slf4j.LoggerFactory
import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import ru.zavanton.demo.entity.UserEntity

@Component
class DataInitializer(
    @PersistenceContext
    private val entityManager: EntityManager
) : CommandLineRunner {

    private val log = LoggerFactory.getLogger(DataInitializer::class.java)

    @Transactional
    override fun run(vararg args: String) {
        val user = UserEntity(name = "Anton")
        entityManager.persist(user)

        // query example
        val query: Query = entityManager.createQuery(
            "select u from UserEntity u where u.id = :userId"
        )
        query.setParameter("userId", 1L)
        val foundUser = query.singleResult as UserEntity
        log.info("zavanton - foundUser: $foundUser")

        // typed query example
        val typedQuery: TypedQuery<UserEntity> = entityManager.createQuery(
            "select u from UserEntity u where u.id = :userId",
            UserEntity::class.java
        )
        typedQuery.setParameter("userId", 1L)
        val foundUser2 = typedQuery.singleResult
        log.info("zavanton - foundUser2: $foundUser2")

        // named query example
        val namedQuery: TypedQuery<UserEntity> = entityManager.createNamedQuery(
            "UserEntity.findByUserId", UserEntity::class.java
        )
        namedQuery.setParameter("userId", 1L)
        val foundUser3 = namedQuery.singleResult
        log.info("zavanton - foundUser3: $foundUser3")

        // native query example
        val nativeQuery = entityManager.createNativeQuery(
            "select * from user_entity where id = :userId",
            UserEntity::class.java
        )
        namedQuery.setParameter("userId", 1L)
        val foundUser4 = namedQuery.singleResult
        log.info("zavanton - foundUser4: $foundUser4")

        // Criteria API query example
        val criteriaBuilder = entityManager.criteriaBuilder
        val criteriaQuery = criteriaBuilder.createQuery(UserEntity::class.java)
        val userRoot = criteriaQuery.from(UserEntity::class.java)
        val foundUser5: UserEntity = entityManager.createQuery(
            criteriaQuery.select(userRoot)
                .where(criteriaBuilder.equal(userRoot.get<Long>("id"), 1L))
        ).singleResult
        log.info("zavanton - foundUser5: $foundUser5")

        // Collection-valued positional parameters
        val myQuery1 = entityManager.createQuery(
            "select u from UserEntity u where u.id in (?1)",
            UserEntity::class.java
        )
        myQuery1.setParameter(1, listOf(1L, 2L))
        val foundUsers1: MutableList<UserEntity> = myQuery1.resultList
        foundUsers1.forEach {
            log.info("zavanton - 1 some found user: $it")
        }

        // Collection-valued named parameters
        val myQuery2 = entityManager.createQuery(
            "select u from UserEntity u where u.id in (:userIds)",
            UserEntity::class.java
        )
        myQuery2.setParameter("userIds", listOf(1L, 2L))
        val foundUsers2: MutableList<UserEntity> = myQuery2.resultList
        foundUsers2.forEach {
            log.info("zavanton - 2 some found user: $it")
        }
    }
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class MyController(
) {
    private val log = LoggerFactory.getLogger(MyController::class.java)

    @GetMapping("")
    fun home(): String {

        return "home"
    }
}










### kotlin/ru/zavanton/demo/entity/UserEntity.kt
package ru.zavanton.demo.entity

import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.NamedQueries
import javax.persistence.NamedQuery

@Entity
@NamedQueries(
    NamedQuery(
        name = "UserEntity.findByUserId",
        query = "select u from UserEntity u where u.id = :userId"
    )
)
class UserEntity(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0L,
    var name: String = ""
) {
    override fun toString(): String {
        return "UserEntity(id=$id, name='$name')"
    }
}
