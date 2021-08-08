# Unit Tests and Spring

### MyController.java
package ru.zavanton.demo.mykdemo.controllers;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import ru.zavanton.demo.mykdemo.service.IMyService;

@RestController
public class MyController {
    private IMyService myService;

    @Autowired
    public MyController(IMyService myService) {
        this.myService = myService;
    }

    @RequestMapping("/")
    public String persons() {
        return myService.load();
    }
}














### MyControllerTest.java
package ru.zavanton.demo.mykdemo.controllers;

import org.junit.jupiter.api.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit4.SpringRunner;
import ru.zavanton.demo.mykdemo.service.IMyService;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.mockito.BDDMockito.given;

@RunWith(SpringRunner.class)
@SpringBootTest
public class MyControllerTest {

    @MockBean
    private IMyService myService;

    @Autowired
    private MyController myController;

    @Test
    void persons() {
        given(this.myService.load()).willReturn("persons");
        assertEquals("persons", myController.persons());
    }
}
