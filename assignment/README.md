# Dart Programming Assignment

This repository contains solutions to a Dart programming assignment consisting of 6 questions. Each question is implemented in a separate Dart file.

## Questions

### Q1: Employee Salary Calculator
Create a Dart program to calculate weekly salaries of employees. If hours worked > 40, extra hours are paid at 1.5 times the hourly rate. Use a class with constructor, methods, and a list of employees to display their final salaries.

**File:** `q1_employee_salary.dart`

### Q2: Online Shopping Cart
Design a shopping cart using a Map where items and prices are stored. Write a function to calculate total bill and handle invalid input like negative quantities or missing items using exceptions. Print the final total after handling errors.

**File:** `q2_shopping_cart.dart`

### Q3: Student Performance Analyzer
Store marks of students in a list of lists. Use higher-order functions (map, reduce, where) to calculate average marks, find highest and lowest scorer, and filter students above a threshold. Display all results neatly.

**File:** `q3_student_performance.dart`

### Q4: Library Management System
Create an abstract class Book with title and author, and an abstract method displayInfo(). Inherit it into EBook (with file size, format) and PrintedBook (with pages). Demonstrate polymorphism by calling displayInfo() for both types.

**File:** `q4_library_management.dart`

### Q5: Railway Ticket Booking
Simulate a ticket booking system using async programming. Use Future.delayed to check seat availability and confirm booking only if seats exist. Handle timeout and print "Booking Confirmed" or "Booking Failed" accordingly.

**File:** `q5_ticket_booking.dart`

### Q6: Bank Transaction System
Build a BankAccount class with a private balance variable. Use getters and setters to safely deposit/withdraw money (no negative or overdraft allowed). Include null safety by keeping account holder name optional. Show operations with balance updates.

**File:** `q6_bank_account.dart`

## Additional Files
- `employee.dart`: An alternative implementation of Q1 (possibly with different logic or names).

## How to Run

To run any of the Dart programs, ensure you have Dart SDK installed. Then, use the following command in the terminal:

```
dart run <filename>.dart
```

For example:
- `dart run q1_employee_salary.dart`
- `dart run q2_shopping_cart.dart` (Note: This program requires user input for quantities)

For programs that require input (like Q2), run them in a terminal where you can provide input.

## Requirements
- Dart SDK (version 2.0 or later recommended for null safety features in Q6)