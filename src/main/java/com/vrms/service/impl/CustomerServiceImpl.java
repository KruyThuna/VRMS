package com.vrms.service.impl;

import com.vrms.exception.ResourceNotFoundException;
import com.vrms.model.Customer;
import com.vrms.repository.CustomerRepository;
import com.vrms.service.CustomerService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
@Transactional
public class CustomerServiceImpl implements CustomerService {

    private final CustomerRepository customerRepository;

    public CustomerServiceImpl(CustomerRepository customerRepository) {
        this.customerRepository = customerRepository;
    }

    @Override
    @Transactional(readOnly = true)
    public List<Customer> getAllCustomers() {
        return customerRepository.findAll();
    }

    @Override
    @Transactional(readOnly = true)
    public Customer getCustomerById(String id) {
        return customerRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Customer not found with ID: " + id));
    }

    @Override
    public Customer saveCustomer(Customer customer) {
        if (customer.getId() == null || customer.getId().trim().isEmpty()) {
            customer.setId("c-" + System.currentTimeMillis());
        }
        return customerRepository.save(customer);
    }

    @Override
    public void deleteCustomer(String id) {
        if (!customerRepository.existsById(id)) {
            throw new ResourceNotFoundException("Cannot delete: Customer not found with ID: " + id);
        }
        customerRepository.deleteById(id);
    }

    @Override
    @Transactional(readOnly = true)
    public long count() {
        return customerRepository.count();
    }
}

