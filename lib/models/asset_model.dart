class Asset {
  final String id;
  final String name;
  final double pricePerUnit;
  final double availableUnits;

  const Asset({
    required this.id,
    required this.name,
    required this.pricePerUnit,
    required this.availableUnits,
  });

  static const List<Asset> assets = [
    Asset(
      id: 'gold24',
      name: 'Gold 24K',
      pricePerUnit: 65.0,
      availableUnits: 10.0,
    ),
    Asset(
      id: 'gold18',
      name: 'Gold 18K',
      pricePerUnit: 50.0,
      availableUnits: 5.0,
    ),
    Asset(
      id: 'silver',
      name: 'Silver',
      pricePerUnit: 1.5,
      availableUnits: 100.0,
    ),
  ];
}
