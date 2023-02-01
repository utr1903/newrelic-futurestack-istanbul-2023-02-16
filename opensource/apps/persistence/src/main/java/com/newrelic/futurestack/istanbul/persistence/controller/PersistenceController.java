package com.newrelic.futurestack.istanbul.persistence.controller;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import com.newrelic.futurestack.istanbul.persistence.dtos.ResponseBase;
import com.newrelic.futurestack.istanbul.persistence.service.post.CreateService;
import com.newrelic.futurestack.istanbul.persistence.service.post.dtos.CreateRequestDto;

import io.opentelemetry.instrumentation.annotations.WithSpan;

@RestController
@RequestMapping("persistence")
public class PersistenceController {

	private final Logger logger = LoggerFactory.getLogger(PersistenceController.class);

	@Autowired
	private CreateService createService;

	@GetMapping("ping")
	public ResponseEntity<String> ping() {
		var response = createResponse();
		return response;
	}

	@WithSpan
	private ResponseEntity<String> createResponse() {
		logger.info("PONG.");
		return new ResponseEntity<>("pong", HttpStatus.OK);
	}

	@PostMapping("create")
	public ResponseEntity<ResponseBase<Boolean>> create(
			@RequestParam(name = "error", defaultValue = "", required = false) String error,
			@RequestBody CreateRequestDto requestDto) {
		logger.info("Create method is triggered...");

		var response = createService.run(
				error, requestDto);

		logger.info("Create method is executed.");

		return response;
	}
}
