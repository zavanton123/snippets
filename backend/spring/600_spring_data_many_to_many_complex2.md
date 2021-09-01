# Spring - Data, Many to many relationships (complex - join table has some more attributes, @ManyToMany)


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










### kotlin/ru/zavanton/demo/repository/GroupRepository.kt
package ru.zavanton.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.Group

@Repository
interface GroupRepository : JpaRepository<Group, Long> {
}










### kotlin/ru/zavanton/demo/repository/UserRepository.kt
package ru.zavanton.demo.repository;

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.entity.User

@Repository
interface UserRepository : JpaRepository<User, Long> {
}










### kotlin/ru/zavanton/demo/runner/DataInitializer.kt
package ru.zavanton.demo.runner

import org.springframework.boot.CommandLineRunner
import org.springframework.stereotype.Component
import ru.zavanton.demo.entity.Group
import ru.zavanton.demo.entity.User
import ru.zavanton.demo.repository.GroupRepository
import ru.zavanton.demo.repository.UserRepository

@Component
class DataInitializer(
    private val userRepository: UserRepository,
    private val groupRepository: GroupRepository,
) : CommandLineRunner {

    override fun run(vararg args: String) {
        val user1 = User(name = "zavanton")
        val group1 = Group(title = "CS")
        user1.addGroup(group1)
        userRepository.save(user1)

        val user2 = User(name = "galina")
        val group2 = Group(title = "Math")
        group2.addUser(user2)
        groupRepository.save(group2)
    }
}










### kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class MyController {

    @GetMapping("")
    fun home(): String {
        return "ok"
    }
}










### kotlin/ru/zavanton/demo/entity/User.kt
package ru.zavanton.demo.entity

import javax.persistence.CascadeType
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.JoinColumn
import javax.persistence.JoinTable
import javax.persistence.ManyToMany
import javax.persistence.Table

@Entity
@Table(name = "users")
data class User(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0L,

    var name: String = ""
) {

    @ManyToMany(cascade = [CascadeType.ALL])
    @JoinTable(
        name = "memberships",
        joinColumns = [JoinColumn(name = "user_id", referencedColumnName = "id")],
        inverseJoinColumns = [JoinColumn(name = "group_id", referencedColumnName = "id")]
    )
    val groups: MutableSet<Group> = mutableSetOf()

    fun addGroup(group: Group) {
        groups.add(group)
        group.users.add(this)
    }
}










### kotlin/ru/zavanton/demo/entity/Group.kt
package ru.zavanton.demo.entity

import javax.persistence.CascadeType
import javax.persistence.Entity
import javax.persistence.GeneratedValue
import javax.persistence.GenerationType
import javax.persistence.Id
import javax.persistence.ManyToMany
import javax.persistence.Table

@Entity
@Table(name = "groups")
data class Group(
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    var id: Long = 0L,

    var title: String = ""
) {

    @ManyToMany(mappedBy = "groups", cascade = [CascadeType.ALL])
    val users: MutableSet<User> = mutableSetOf()

    fun addUser(user: User) {
        users.add(user)
        user.groups.add(this)
    }
}










### kotlin/ru/zavanton/demo/entity/Membership.kt
package ru.zavanton.demo.entity

import java.io.Serializable
import java.util.Date
import javax.persistence.Column
import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.Table
import javax.persistence.Temporal
import javax.persistence.TemporalType

@Entity
@Table(name = "memberships")
data class Membership(
    @Id
    @Column(name = "user_id", insertable = false, updatable = false)
    var userId: Long,

    @Id
    @Column(name = "group_id", insertable = false, updatable = false)
    var groupId: Long,

    @Temporal(TemporalType.DATE)
    var membershipDate: Date = Date()
) : Serializable
