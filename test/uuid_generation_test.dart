import 'package:flutter_test/flutter_test.dart';
import 'package:notdle/models/measurement.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/company.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Entity UUID Generation Tests', () {
    test('Measurement should generate a valid UUID', () {
      final measurement = Measurement(
        customerId: 'customer-123',
        name: 'Test Measurement',
        measurementValues: {'Waist': 34.0},
        createdDate: DateTime.now(),
      );
      expect(measurement.id, isNotNull);
      expect(Uuid.isValidUUID(fromString: measurement.id), isTrue);
    });

    test('Customer should generate a valid UUID', () {
      final customer = Customer(
        name: 'John Doe',
        phone: '1234567890',
        lastVisit: DateTime.now(),
        gender: 'Male',
        createdDate: DateTime.now(),
      );
      expect(customer.id, isNotNull);
      expect(Uuid.isValidUUID(fromString: customer.id!), isTrue);
    });

    test('Invoice should generate a valid UUID', () {
      final invoice = Invoice(customerId: 'customer-123', status: 'Unpaid');
      expect(invoice.id, isNotNull);
      expect(Uuid.isValidUUID(fromString: invoice.id), isTrue);
    });

    test('Company should generate a valid UUID', () {
      final company = Company(
        businessName: 'Test Business',
        ownerName: 'Test Owner',
        email: 'test@example.com',
        mobile: '1234567890',
        yearsOfExperience: 5,
        registrationNumber: 'REG123',
        countryCode: 'GH',
        address: '123 Test St',
      );
      expect(company.id, isNotNull);
      expect(Uuid.isValidUUID(fromString: company.id), isTrue);
    });
  });
}
