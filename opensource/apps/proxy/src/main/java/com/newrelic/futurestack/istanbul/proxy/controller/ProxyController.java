package com.newrelic.futurestack.istanbul.proxy.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("proxy")
public class ProxyController {

    private final Logger logger = LoggerFactory.getLogger(ProxyController.class);

    @GetMapping("ping")
    public ResponseEntity<String> ping() {
        logger.info("Java second method is triggered...");

        var response = new ResponseEntity<>("pong", HttpStatus.OK);

        logger.info("Java second method is executed.");

        return response;
    }
}
