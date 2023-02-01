package com.newrelic.futurestack.istanbul.persistence.service.create;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class CreateServiceKafka {

  private final Logger logger = LoggerFactory.getLogger(CreateServiceKafka.class);

  @KafkaListener(topics = "create", groupId = "persistence-oss")
  public void createPipelineData(
      String message) {
    logger.info(message);
  }
}
