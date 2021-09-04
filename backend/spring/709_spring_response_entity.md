package ru.zavanton.demo.controller

import org.springframework.http.HttpHeaders
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.ResponseStatus
import org.springframework.web.bind.annotation.RestController

@RestController
class MyController {

    @GetMapping("/")
    @ResponseStatus()
    fun demo(): ResponseEntity<String> {
        val headers = HttpHeaders()
        headers.add("Content-Type", "application/json")
        return ResponseEntity(
            "hello world 1",
            headers,
            HttpStatus.OK
        )
    }

    @GetMapping("/more")
    fun more(): ResponseEntity<String> {
        return ResponseEntity
            //.status(HttpStatus.OK)
            .ok()
            .headers(
                HttpHeaders().apply { add("Content-Type", "application/json") }
            )
            .body("hello world 2")
    }
}
