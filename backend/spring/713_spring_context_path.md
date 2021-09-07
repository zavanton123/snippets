# Spring - How to change context path?

Source:
https://www.baeldung.com/spring-boot-context-path

### application.properties
```
server.servlet.context-path=/baeldung

```



### App.java
```
public static void main(String[] args) {
    System.setProperty("server.servlet.context-path", "/baeldung");
    SpringApplication.run(Application.class, args);
}
```



### OS environment variable
```
$ export SERVER_SERVLET_CONTEXT_PATH=/baeldung
```



### Command line arguments
```
$ java -jar app.jar --server.servlet.context-path=/baeldung
```




### Java config
```
@Bean
public WebServerFactoryCustomizer<ConfigurableServletWebServerFactory>
  webServerFactoryCustomizer() {
    return factory -> factory.setContextPath("/baeldung");
}
```
