# Spring - advanced example of creating custom auto configuration (spring.factories, @Conditional, SpringBootCondition, @ConditionalOnClass, @ConditionalOnBean, @ConditionalOnMissingBean, @ConditionalOnProperty, @ConditionalOnResource, @ConditionalOnWebApplication, @EnableConfigurationProperties, @ConfigurationProperties)




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










### test/kotlin/ru/zavanton/demo/AutoConfigurationTest.kt
package ru.zavanton.demo

import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import ru.zavanton.demo.data.MyUser
import ru.zavanton.demo.repository.MyUserRepository

@SpringBootTest
class AutoConfigurationTest {

    @Autowired
    private lateinit var myUserRepository: MyUserRepository

    @Test
    fun `test save user`() {
        val user = MyUser("zavanton@yandex.ru")
        val savedUser = myUserRepository.save(user)
        assertThat(savedUser.email).isEqualTo(user.email)
    }
}










### main/resources/mysql.properties
usemysql=local

mysql-hibernate.dialect=org.hibernate.dialect.MariaDBDialect
mysql-hibernate.show_sql=true
mysql-hibernate.hbm2ddl.auto=create-drop

mysql.url=jdbc:mysql://localhost:3306/auto_config_db?createDatabaseIfNotExist=true
mysql.user=zavanton
mysql.password=some-pass-here










### main/resources/application.yml
server:
  port: 9999










### main/resources/META-INF/spring.factories
org.springframework.boot.autoconfigure.EnableAutoConfiguration=\
ru.zavanton.demo.config.MySQLAutoConfiguration










### main/kotlin/ru/zavanton/demo/App.kt
package ru.zavanton.demo

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
    runApplication<App>(*args)
}










### main/kotlin/ru/zavanton/demo/repository/MyUserRepository.kt
package ru.zavanton.demo.repository

import org.springframework.data.jpa.repository.JpaRepository
import org.springframework.stereotype.Repository
import ru.zavanton.demo.data.MyUser

@Repository
interface MyUserRepository: JpaRepository<MyUser, String> {
}










### main/kotlin/ru/zavanton/demo/config/HibernateCondition.kt
package ru.zavanton.demo.config

import org.springframework.boot.autoconfigure.condition.ConditionMessage
import org.springframework.boot.autoconfigure.condition.ConditionOutcome
import org.springframework.boot.autoconfigure.condition.SpringBootCondition
import org.springframework.context.annotation.ConditionContext
import org.springframework.core.type.AnnotatedTypeMetadata
import org.springframework.util.ClassUtils

// Create a custom condition by extending SpringBootCondition
class HibernateCondition : SpringBootCondition() {

    private val classes = listOf(
        "org.hibernate.ejb.HibernateEntityManager",
        "org.hibernate.jpa.HibernateEntityManager"
    )

    override fun getMatchOutcome(
        context: ConditionContext,
        metadata: AnnotatedTypeMetadata
    ): ConditionOutcome {
        val message = ConditionMessage.forCondition("Hibernate")
        return classes.filter { className ->
            ClassUtils.isPresent(className, context.classLoader)
        }.map { targetClassName ->
            ConditionOutcome
                .match(
                    message.found("class")
                        .items(ConditionMessage.Style.NORMAL, targetClassName)
                )
        }.getOrElse(0) {
            ConditionOutcome
                .noMatch(
                    message.didNotFind("class", "classes")
                        .items(ConditionMessage.Style.NORMAL, classes)
                )
        }
    }
}










### main/kotlin/ru/zavanton/demo/config/MySQLCustomProperties.kt
package ru.zavanton.demo.config

import org.springframework.boot.context.properties.ConfigurationProperties

@ConfigurationProperties(prefix = "mysql")
class MySQLCustomProperties(
    var url: String? = null,
    var user: String? = null,
    var password: String? = null
)










### main/kotlin/ru/zavanton/demo/config/MySQLAutoConfiguration.kt
package ru.zavanton.demo.config

import java.util.Properties
import javax.persistence.EntityManagerFactory
import javax.sql.DataSource
import org.springframework.boot.autoconfigure.AutoConfigureOrder
import org.springframework.boot.autoconfigure.condition.ConditionalOnBean
import org.springframework.boot.autoconfigure.condition.ConditionalOnClass
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty
import org.springframework.boot.autoconfigure.condition.ConditionalOnResource
import org.springframework.boot.autoconfigure.condition.ConditionalOnWebApplication
import org.springframework.boot.context.properties.EnableConfigurationProperties
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Conditional
import org.springframework.context.annotation.Configuration
import org.springframework.context.annotation.PropertySource
import org.springframework.core.Ordered
import org.springframework.core.env.Environment
import org.springframework.jdbc.datasource.DriverManagerDataSource
import org.springframework.orm.jpa.JpaTransactionManager
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter

@Configuration
// this auto config has the highest precedence
@AutoConfigureOrder(Ordered.HIGHEST_PRECEDENCE)
// this auto config is active only if the DataSource class  is on the classpath
@ConditionalOnClass(DataSource::class)
// this auto config is only for web applications
@ConditionalOnWebApplication
// show the address of the properties file
@PropertySource("classpath:mysql.properties")
// enable custom properties
@EnableConfigurationProperties(MySQLCustomProperties::class)
class MySQLAutoConfiguration(
    // inject custom properties
    private val customProperties: MySQLCustomProperties,
    // other properties can be accessed from the environment
    private val env: Environment,
) {

    // note: the name of the bean is the name of the method dataSource()
    @Bean
    @ConditionalOnProperty(
        name = ["usemysql"],
        havingValue = "local",
        matchIfMissing = true
    )
    @ConditionalOnMissingBean
    fun dataSource(): DataSource {
        val dataSource = DriverManagerDataSource()
        dataSource.setDriverClassName("com.mysql.cj.jdbc.Driver")
        dataSource.url = "jdbc:mysql://localhost:3306/demo_auto_config?createDatabaseIfNotExist=true"
        dataSource.username = "zavanton"
        dataSource.password = "some-pass-here"
        return dataSource
    }

    @Bean(name = ["dataSource"])
    @ConditionalOnProperty(
        name = ["usemysql"],
        havingValue = "custom"
    )
    @ConditionalOnMissingBean(name = ["dataSource"])
    fun customDataSource(): DataSource {
        val dataSource = DriverManagerDataSource()
        dataSource.setDriverClassName("com.mysql.cj.jdbc.Driver")
        dataSource.url = customProperties.url ?: ""
        dataSource.username = customProperties.user ?: ""
        dataSource.password = customProperties.password ?: ""
        return dataSource
    }

    @Bean
    @ConditionalOnBean(name = ["dataSource"])
    @ConditionalOnMissingBean
    fun entityManagerFactory(): LocalContainerEntityManagerFactoryBean {
        val factoryBean = LocalContainerEntityManagerFactoryBean()
        factoryBean.dataSource = dataSource()
        factoryBean.setPackagesToScan("ru.zavanton.demo")
        factoryBean.jpaVendorAdapter = HibernateJpaVendorAdapter()
        val additionalProperties = additionalProperties()
        if (additionalProperties != null) {
            factoryBean.setJpaProperties(additionalProperties)
        }
        return factoryBean
    }

    @Bean
    @ConditionalOnMissingBean(type = ["JpaTransactionManager"])
    fun transactionManager(entityManagerFactory: EntityManagerFactory): JpaTransactionManager {
        val transactionManager = JpaTransactionManager()
        transactionManager.entityManagerFactory = entityManagerFactory
        return transactionManager
    }

    // Note: we could create a custom ConfigurationProperties class
    // for these properties, but here we just read the properties
    // from the environment
    @ConditionalOnResource(resources = ["classpath:mysql.properties"])
    @Conditional(HibernateCondition::class)
    fun additionalProperties(): Properties? {
        val hibernateProperties = Properties()
        hibernateProperties.setProperty(
            "hibernate.hbm2ddl.auto",
            env.getProperty("mysql-hibernate.hbm2ddl.auto")
        )
        hibernateProperties.setProperty(
            "hibernate.dialect",
            env.getProperty("mysql-hibernate.dialect")
        )
        hibernateProperties.setProperty(
            "hibernate.show_sql",
            if (env.getProperty("mysql-hibernate.show_sql") != null) {
                env.getProperty("mysql-hibernate.show_sql")
            } else {
                "false"
            }
        )
        return hibernateProperties
    }
}










### main/kotlin/ru/zavanton/demo/data/MyUser.kt
package ru.zavanton.demo.data

import javax.persistence.Entity
import javax.persistence.Id
import javax.persistence.Table

@Entity
@Table(name = "users")
class MyUser(
    @Id
    var email: String = ""
)










### main/kotlin/ru/zavanton/demo/controller/MyController.kt
package ru.zavanton.demo.controller

import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RestController
import ru.zavanton.demo.data.MyUser
import ru.zavanton.demo.repository.MyUserRepository

@RestController
class MyController(
    private val myUserRepository: MyUserRepository
) {

    @GetMapping("")
    fun home(): String {
        val user = MyUser("zavanton")
        val savedUser = myUserRepository.save(user)
        return savedUser.email
    }
}
