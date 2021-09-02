package ru.zavanton.demo.controller

import org.slf4j.LoggerFactory
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestParam
import org.springframework.web.bind.annotation.RestController

@RestController
class MyController {
private val log = LoggerFactory.getLogger(MyController::class.java)

    // example:
    // http://localhost:9999/map?name=Anton&age=123
    @GetMapping("/map")
    fun getParamsAsMap(
        @RequestParam data: Map<String, String>
    ): String {
        data.entries.forEach {
            log.info("zavanton - ${it.key} -> ${it.value}")
        }
        return "ok"
    }

    // example:
    // http://localhost:9999/list?nums=1,2,3,4,5
    @GetMapping("/list")
    fun getParamsAsList(
        @RequestParam("nums") numbers: List<Int>
    ): String {
        numbers.forEach {
            log.info("zavanton - number: $it")
        }
        return "lists"
    }
}
