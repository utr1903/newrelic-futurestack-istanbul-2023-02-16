package com.newrelic.futurestack.istanbul.persistence.service.post.dtos;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class CreateRequestDto {

  private String name;

  private String value;
}
