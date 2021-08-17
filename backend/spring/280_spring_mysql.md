# Spring - How to connect to MySQL?


### build.gradle.kts
import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

plugins {
	id("org.springframework.boot") version "2.5.3"
	id("io.spring.dependency-management") version "1.0.11.RELEASE"
	kotlin("jvm") version "1.5.21"
	kotlin("plugin.spring") version "1.5.21"
	kotlin("plugin.jpa") version "1.5.21"
}

group = "ru.zavanton"
version = "0.0.1-SNAPSHOT"
java.sourceCompatibility = JavaVersion.VERSION_1_8

repositories {
	mavenCentral()
}

dependencies {
	implementation("org.springframework.boot:spring-boot-starter-data-jpa")
	implementation("org.springframework.boot:spring-boot-starter-web")
	implementation("com.fasterxml.jackson.module:jackson-module-kotlin")
	implementation("org.jetbrains.kotlin:kotlin-reflect")
	implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk8")
	developmentOnly("org.springframework.boot:spring-boot-devtools")
	implementation("mysql:mysql-connector-java")
	testImplementation("org.springframework.boot:spring-boot-starter-test")
	implementation("org.springframework.boot:spring-boot-starter-thymeleaf")
	implementation("org.springframework.boot:spring-boot-starter-validation")
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








### application.yml
server:
  port: 9999
spring:
  datasource:
    driverClassName: com.mysql.cj.jdbc.Driver
    password: some-pass-here
    url: jdbc:mysql://localhost:3306/university?serverTimezone=UTC
    username: zavanton
  jpa:
    database-platform: org.hibernate.dialect.MySQL5InnoDBDialect
    defer-datasource-initialization: true
    show-sql: false
    hibernate:
      ddl-auto: update
#    # this auto generates a schema from entities
#    properties:
#      javax:
#        persistence:
#          schema-generation:
#            create-source: metadata
#            scripts:
#              action: create
#              create-target: db_create.sq
