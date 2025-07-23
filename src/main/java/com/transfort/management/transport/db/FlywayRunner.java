package com.transfort.management.transport.db;

import javax.sql.DataSource;

import org.flywaydb.core.Flyway;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.flyway.FlywayDataSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.jdbc.datasource.DriverManagerDataSource;

@Configuration
public class FlywayRunner {

	@Autowired
	private DataSourceProps dataSourceProps;

	@Bean
	@FlywayDataSource
	public DataSource flywayDataSource() {
		DriverManagerDataSource dataSource = new DriverManagerDataSource();
		// dataSource.setUrl(dataSourceProps.getUrl() + "?createDatabaseIfNotExist=true");
		dataSource.setUrl(dataSourceProps.getUrl());
		System.out.println(dataSourceProps.getUrl());
		dataSource.setUsername(dataSourceProps.getUsername());
		dataSource.setPassword(dataSourceProps.getPassword());
		dataSource.setDriverClassName("com.mysql.cj.jdbc.Driver");
		return dataSource;
	}

	@Bean(initMethod = "migrate")
	public Flyway flyway() {
		Flyway flyway = Flyway.configure().dataSource(flywayDataSource())
				.locations("classpath:db/migration/transport").load();
		return flyway;
	}
	
}
