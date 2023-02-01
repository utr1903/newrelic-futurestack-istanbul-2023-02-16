package com.newrelic.futurestack.istanbul.persistence.service.create;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

@Service
public class CreateServiceKafka {

  private final Logger logger = LoggerFactory.getLogger(CreateServiceKafka.class);

  @KafkaListener(topics = "#{'${KAFKA_TOPIC}'}", groupId = "#{'${KAFKA_CONSUMER_GROUP_ID}'}")
  public void createPipelineData(
      String message) {
    logger.info(message);
  }
}
