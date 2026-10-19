enum UserRole {
  admin('Administrator', 'Full system access, inventory posting, bookings control & revenue'),
  manager('Fleet Manager', 'Inventory and maintenance scheduling'),
  customer('Customer', 'Vehicle reservations & rental cart'),
  guest('Guest', 'Public storefront browsing');

  final String label;
  final String description;
  const UserRole(this.label, this.description);
}

