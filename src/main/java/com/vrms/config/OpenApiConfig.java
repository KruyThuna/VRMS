package com.vrms.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.info.License;
import io.swagger.v3.oas.models.servers.Server;
import io.swagger.v3.oas.models.tags.Tag;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    @Bean
    public OpenAPI vrmsOpenAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title(" VRMS REST API")
                        .description("Vehicle Rental Management System API")
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("DriveLine Car Rental")
                                .email("booking@driveline-rental.com")
                                .url("http://localhost:8080"))
                        .license(new License().name("Apache 2.0").url("https://springdoc.org")))
                .servers(List.of(
                        new Server().url("http://localhost:8080").description("Local Development Server")
                ))
                .tags(List.of(
                        new Tag().name("0. System & Sync").description("System health monitoring and client full-data synchronization"),
                        new Tag().name("1. Fleet & Vehicles").description("Vehicle catalog, technical specifications, rental pricing, and stock availability"),
                        new Tag().name("2. Bookings & Rentals").description("Customer rental reservations, contracts, returns, and payment management"),
                        new Tag().name("3. Customer Directory").description("Customer registrations, contact information, and driver license verification"),
                        new Tag().name("4. Marketing Banners").description("Showcase hero banners, promotional cards, and highlighted vehicles"),
                        new Tag().name("5. Agency Profile").description("Agency corporate branding, contact numbers, address, and headquarters profile"),
                        new Tag().name("6. Leads & Inquiries").description("Customer vehicle inquiries, test drive requests, and quote submissions")
                ));
    }
}
