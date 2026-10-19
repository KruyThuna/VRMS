package com.vrms.service;

import com.vrms.model.Customer;
import java.util.List;

public interface CustomerService {
    List<Customer> getAllCustomers();
    Customer getCustomerById(String id);
    Customer saveCustomer(Customer customer);
    void deleteCustomer(String id);
    long count();
}

