 
class Employee {
 
  String name;
  double hourlyRate;
  double hoursWorked;

 
  Employee(this.name, this.hourlyRate, this.hoursWorked);

 
  double calculateSalary() {
    const double regularHours = 40.0;
    const double overtimeMultiplier = 1.5;
    double totalSalary;

    if (hoursWorked <= regularHours) {
  
      totalSalary = hoursWorked * hourlyRate;
    } else {
    
      double regularPay = regularHours * hourlyRate;
      double overtimeHours = hoursWorked - regularHours;
      double overtimePay = overtimeHours * (hourlyRate * overtimeMultiplier);
      totalSalary = regularPay + overtimePay;
    }
    
    return totalSalary;
  }
}

void main() {

  List<Employee> employees = [
    Employee('Om', 20.0, 38.0),    
    Employee('Choksi', 25.0, 45.0),     
    Employee('Hari', 30.0, 40.0),  
    Employee('Sans', 22.5, 50.0),    
  ];

  print("--- Weekly Employee Salaries ---");
 
  for (var employee in employees) {
    double finalSalary = employee.calculateSalary();
  
    print(
        '${employee.name}: \t Worked ${employee.hoursWorked} hours. Final Salary: \$${finalSalary.toStringAsFixed(2)}');
  }
}