# Spring Bean Lifecycle - BeanPostProcessor, InitializingBean, DisposableBean, BeanNameAware, BeanFactoryAware, ApplicationContextAware, @PostConstruct, @PreDestroy


### ./App.kt
package ru.zavanton.profile

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication

@SpringBootApplication
class App

fun main(args: Array<String>) {
	runApplication<App>(*args)
}







### lifecycle/CustomBeanPostProcessor.kt
package ru.zavanton.profile.lifecycle

import org.springframework.beans.factory.config.BeanPostProcessor
import org.springframework.stereotype.Component

@Component
class CustomBeanPostProcessor : BeanPostProcessor {

    override fun postProcessBeforeInitialization(bean: Any, beanName: String): Any? {
        if (bean is CustomComponent) {
            bean.postProcessBeforeInitialization()
        }
        return bean
    }

    override fun postProcessAfterInitialization(bean: Any, beanName: String): Any? {
        if (bean is CustomComponent) {
            bean.postProcessAfterInitialization()
        }
        return bean
    }
}









### lifecycle/CustomComponent.kt
package ru.zavanton.profile.lifecycle

import org.slf4j.LoggerFactory
import org.springframework.beans.factory.*
import org.springframework.context.ApplicationContext
import org.springframework.context.ApplicationContextAware
import org.springframework.stereotype.Component

@Component
class CustomComponent : InitializingBean,
    DisposableBean,
    BeanNameAware,
    BeanFactoryAware,
    ApplicationContextAware {

    private val log = LoggerFactory.getLogger(CustomComponent::class.java.name)

    override fun afterPropertiesSet() {
        log.info("zavanton - afterPropertiesSet")
    }

    override fun destroy() {
        log.info("zavanton - destroy")
    }

    override fun setBeanName(name: String) {
        log.info("zavanton- setBeanName: $name")
    }

    override fun setBeanFactory(beanFactory: BeanFactory) {
        log.info("zavanton - setBeanFactory")
    }

    override fun setApplicationContext(applicationContext: ApplicationContext) {
        log.info("zavanton - setApplicationContext")
    }

    fun postProcessBeforeInitialization() {
        log.info("zavanton - postProcessBeforeInitialization")
    }

    fun postProcessAfterInitialization() {
        log.info("zavanton - postProcessAfterInitialization")
    }
}
