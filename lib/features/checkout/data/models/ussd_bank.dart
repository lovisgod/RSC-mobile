class UssdBank {
  final String name;
  final String ussdCode;

  const UssdBank({required this.name, required this.ussdCode});

  static const List<UssdBank> banks = [
    UssdBank(name: 'GTBank', ussdCode: '*737#'),
    UssdBank(name: 'UBA', ussdCode: '*919#'),
    UssdBank(name: 'Access Bank', ussdCode: '*901#'),
    UssdBank(name: 'Zenith Bank', ussdCode: '*966#'),
  ];
}
