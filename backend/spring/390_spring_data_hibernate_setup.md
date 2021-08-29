### resources/application.yml
server:
  port: 9999












### kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}










### kotlin/ru/zavanton/demo/conf/HibernateConf.kt
package ru.zavanton.demo.conf

import java.util.Properties
import javax.sql.DataSource
import org.apache.tomcat.dbcp.dbcp2.BasicDataSource
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.orm.hibernate5.HibernateTransactionManager
import org.springframework.orm.hibernate5.LocalSessionFactoryBean
import org.springframework.transaction.PlatformTransactionManager
import org.springframework.transaction.annotation.EnableTransactionManagement
import org.springframework.transaction.annotation.TransactionManagementConfigurer

@Configuration
@EnableTransactionManagement
class HibernateConf : TransactionManagementConfigurer {

    @Bean
    override fun annotationDrivenTransactionManager(): PlatformTransactionManager {
        val transactionManager = HibernateTransactionManager()
        transactionManager.sessionFactory = sessionFactory().getObject()
        return transactionManager
    }

    @Bean
    fun sessionFactory(): LocalSessionFactoryBean {
        val sessionFactory = LocalSessionFactoryBean()
        sessionFactory.setDataSource(dataSource())
        sessionFactory.setPackagesToScan("ru.zavanton.demo.data")
        sessionFactory.hibernateProperties = hibernateProperties()
        return sessionFactory
    }

    @Bean
    fun dataSource(): DataSource {
        val dataSource = BasicDataSource()
        dataSource.driverClassName = "org.h2.Driver"
        dataSource.url = "jdbc:h2:mem:db;DB_CLOSE_DELAY=-1"
        dataSource.username = "admin"
        dataSource.password = "admin"
        return dataSource
    }

    private fun hibernateProperties(): Properties {
        val hibernateProperties = Properties()
        hibernateProperties.setProperty("hibernate.hbm2ddl.auto", "create-drop")
        hibernateProperties.setProperty("hibernate.dialect", "org.hibernate.dialect.H2Dialect")
        return hibernateProperties
    }
}










### kotlin/ru/zavanton/demo/controller/HomeController.kt
package ru.zavanton.demo.controller

import org.hibernate.SessionFactory
import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController

@RestController
class HomeController(
    private val sessionFactory: SessionFactory
) {

    private val log = LoggerFactory.getLogger(HomeController::class.java)

    @GetMapping("")
    fun home(): String {
        log.info("zavanton - sessionFactory: ${sessionFactory.isClosed}")
        return "ok"
    }
}