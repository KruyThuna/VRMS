import 'app_language.dart';

class AppTranslations {
  static final Map<String, Map<AppLanguage, String>> _strings = {
    // App & Nav
    'app_title': {
      AppLanguage.english: 'DriveLine • Premium Cars & Rental Agency',
      AppLanguage.khmer: 'DriveLine • សេវាកម្មជួលរថយន្តទំនើប',
    },
    'home': {
      AppLanguage.english: 'Home',
      AppLanguage.khmer: 'ទំព័រដើម',
    },
    'fleet': {
      AppLanguage.english: 'Fleet',
      AppLanguage.khmer: 'រថយន្តទាំងអស់',
    },
    'admin_workspace': {
      AppLanguage.english: 'Admin Workspace',
      AppLanguage.khmer: 'ផ្ទាំងគ្រប់គ្រងរដ្ឋបាល',
    },
    'cart': {
      AppLanguage.english: 'Reservation Cart',
      AppLanguage.khmer: 'កន្ត្រកកក់រថយន្ត',
    },
    'empty_cart': {
      AppLanguage.english: 'Your cart is empty',
      AppLanguage.khmer: 'កន្ត្រករបស់អ្នកទទេ',
    },

    // Vehicle & HUD Actions
    'post_new_vehicle': {
      AppLanguage.english: 'Post New Vehicle / Product',
      AppLanguage.khmer: 'បន្ថែមរថយន្ត / ផលិតផលថ្មី',
    },
    'edit_vehicle': {
      AppLanguage.english: 'Edit Vehicle',
      AppLanguage.khmer: 'កែប្រែព័ត៌មានរថយន្ត',
    },
    'reserve_now': {
      AppLanguage.english: 'Reserve Now',
      AppLanguage.khmer: 'កក់ទុកឥឡូវនេះ',
    },
    'add_to_cart': {
      AppLanguage.english: 'Add to Cart',
      AppLanguage.khmer: 'ដាក់ក្នុងកន្ត្រក',
    },
    'in_cart': {
      AppLanguage.english: 'In Cart',
      AppLanguage.khmer: 'ក្នុងកន្ត្រក',
    },
    'view_details': {
      AppLanguage.english: 'View Details',
      AppLanguage.khmer: 'មើលព័ត៌មានលម្អិត',
    },
    'available': {
      AppLanguage.english: 'Available',
      AppLanguage.khmer: 'ទំនេរ / អាចជួលបាន',
    },
    'in_maintenance': {
      AppLanguage.english: 'In Maintenance',
      AppLanguage.khmer: 'កំពុងជួសជុលថែទាំ',
    },
    'daily_rate': {
      AppLanguage.english: 'Daily Rate',
      AppLanguage.khmer: 'តម្លៃក្នុងមួយថ្ងៃ',
    },
    'per_day': {
      AppLanguage.english: '/ day',
      AppLanguage.khmer: '/ ថ្ងៃ',
    },

    // Cyber HUD Specifications
    'specs': {
      AppLanguage.english: 'Specifications',
      AppLanguage.khmer: 'លក្ខណៈបច្ចេកទេស',
    },
    'engine': {
      AppLanguage.english: 'Engine',
      AppLanguage.khmer: 'កម្លាំងម៉ាស៊ីន',
    },
    'horsepower': {
      AppLanguage.english: 'Horsepower',
      AppLanguage.khmer: 'កម្លាំងសេះ',
    },
    'top_speed': {
      AppLanguage.english: 'Top Speed',
      AppLanguage.khmer: 'ល្បឿនអតិបរមា',
    },
    'acceleration': {
      AppLanguage.english: '0-100 Acceleration',
      AppLanguage.khmer: 'សន្ទុះល្បឿន 0-100',
    },
    'transmission': {
      AppLanguage.english: 'Transmission',
      AppLanguage.khmer: 'ប្រអប់លេខ',
    },
    'seats': {
      AppLanguage.english: 'Seats',
      AppLanguage.khmer: 'ចំនួនកៅអី',
    },
    'fuel': {
      AppLanguage.english: 'Fuel Type',
      AppLanguage.khmer: 'ប្រភេទប្រេង',
    },

    // Checkout & Cart
    'checkout': {
      AppLanguage.english: 'Checkout',
      AppLanguage.khmer: 'ទូទាត់ប្រាក់',
    },
    'total': {
      AppLanguage.english: 'Total',
      AppLanguage.khmer: 'សរុប',
    },
    'total_rental': {
      AppLanguage.english: 'Total Estimated Rental',
      AppLanguage.khmer: 'តម្លៃសរុបប៉ាន់ស្មាន',
    },
    'apply_voucher': {
      AppLanguage.english: 'Apply Promo Voucher',
      AppLanguage.khmer: 'បញ្ចូលកូដបញ្ចុះតម្លៃ',
    },
    'apply': {
      AppLanguage.english: 'Apply',
      AppLanguage.khmer: 'អនុវត្ត',
    },
    'confirm_reservation': {
      AppLanguage.english: 'Confirm Reservation',
      AppLanguage.khmer: 'បញ្ជាក់ការកក់ទុក',
    },
    'renter_details': {
      AppLanguage.english: 'Renter Details',
      AppLanguage.khmer: 'ព័ត៌មានអ្នកជួល',
    },
    'full_name': {
      AppLanguage.english: 'Full Name',
      AppLanguage.khmer: 'ឈ្មោះពេញ',
    },
    'phone_number': {
      AppLanguage.english: 'Phone Number',
      AppLanguage.khmer: 'លេខទូរស័ព្ទ',
    },
    'email_address': {
      AppLanguage.english: 'Email Address',
      AppLanguage.khmer: 'អាសយដ្ឋានអ៊ីមែល',
    },
    'pickup_date': {
      AppLanguage.english: 'Pickup Date',
      AppLanguage.khmer: 'កាលបរិច្ឆេទទទួលរថយន្ត',
    },
    'due_date': {
      AppLanguage.english: 'Due Date (Return)',
      AppLanguage.khmer: 'កាលបរិច្ឆេទប្រគល់រថយន្ត (Due Date)',
    },
    'select_dates': {
      AppLanguage.english: 'Select Dates',
      AppLanguage.khmer: 'ជ្រើសរើសកាលបរិច្ឆេទ',
    },
    'booking_user_name': {
      AppLanguage.english: 'Booking User Name',
      AppLanguage.khmer: 'ឈ្មោះអ្នកកក់រថយន្ត',
    },
    'registered_renters': {
      AppLanguage.english: 'Quick Fill (Registered Customers)',
      AppLanguage.khmer: 'ជ្រើសរើសរហ័ស (អតិថិជនបានចុះឈ្មោះ)',
    },
    'days_rental': {
      AppLanguage.english: 'Days Rental',
      AppLanguage.khmer: 'ថ្ងៃជួល',
    },
    'balance_due': {
      AppLanguage.english: 'Total Amount Due',
      AppLanguage.khmer: 'ទឹកប្រាក់សរុបដែលត្រូវទូទាត់',
    },

    // Dialogs & Buttons
    'cancel': {
      AppLanguage.english: 'Cancel',
      AppLanguage.khmer: 'បោះបង់',
    },
    'save_changes': {
      AppLanguage.english: 'Save Changes',
      AppLanguage.khmer: 'រក្សាទុកការផ្លាស់ប្តូរ',
    },
    'post_product': {
      AppLanguage.english: 'Post Product',
      AppLanguage.khmer: 'បង្ហោះផលិតផល',
    },
    'delete': {
      AppLanguage.english: 'Delete',
      AppLanguage.khmer: 'លុប',
    },
    'close': {
      AppLanguage.english: 'Close',
      AppLanguage.khmer: 'បិទ',
    },
    'language': {
      AppLanguage.english: 'Language',
      AppLanguage.khmer: 'ភាសា',
    },

    // Navigation & Storefront Sections
    'about': {
      AppLanguage.english: 'About',
      AppLanguage.khmer: 'អំពីយើង',
    },
    'services': {
      AppLanguage.english: 'Services',
      AppLanguage.khmer: 'សេវាកម្ម',
    },
    'testimonials': {
      AppLanguage.english: 'Testimonials',
      AppLanguage.khmer: 'មតិអតិថិជន',
    },
    'contact': {
      AppLanguage.english: 'Contact',
      AppLanguage.khmer: 'ទំនាក់ទំនង',
    },
    'book_test_drive': {
      AppLanguage.english: 'Reserve Now',
      AppLanguage.khmer: 'កក់រថយន្តឥឡូវនេះ',
    },
    'book_rental': {
      AppLanguage.english: 'Book a Rental',
      AppLanguage.khmer: 'កក់រថយន្តជួល',
    },
    'search_inventory': {
      AppLanguage.english: 'Search Inventory',
      AppLanguage.khmer: 'ស្វែងរករថយន្ត',
    },
    'admin_management': {
      AppLanguage.english: 'Admin Management Hub',
      AppLanguage.khmer: 'មជ្ឈមណ្ឌលគ្រប់គ្រងរដ្ឋបាល',
    },
    'dashboard': {
      AppLanguage.english: 'Dashboard',
      AppLanguage.khmer: 'ផ្ទាំងគ្រប់គ្រងសង្ខេប',
    },
    'fleet_products': {
      AppLanguage.english: 'Fleet & Products',
      AppLanguage.khmer: 'រថយន្ត និងផលិតផល',
    },
    'hero_banners': {
      AppLanguage.english: 'Hero Banners',
      AppLanguage.khmer: 'ផ្ទាំងផ្សាយពាណិជ្ជកម្ម',
    },
    'categories_brand': {
      AppLanguage.english: 'Categories & Brand',
      AppLanguage.khmer: 'ប្រភេទទំនិញ & ម៉ាក',
    },
    'customers': {
      AppLanguage.english: 'Customers',
      AppLanguage.khmer: 'អតិថិជន',
    },
    'bookings': {
      AppLanguage.english: 'Bookings',
      AppLanguage.khmer: 'ការកក់រថយន្ត',
    },
    'return_car': {
      AppLanguage.english: 'Return Car',
      AppLanguage.khmer: 'ប្រគល់រថយន្ត',
    },
    'returns_hub_title': {
      AppLanguage.english: 'Fleet Returns & Check-In Hub',
      AppLanguage.khmer: 'មជ្ឈមណ្ឌលត្រួតពិនិត្យ & ប្រគល់រថយន្ត',
    },
    'returns_hub_subtitle': {
      AppLanguage.english: 'Process vehicle check-ins, verify return conditions, settle balances, and record unpaid debts.',
      AppLanguage.khmer: 'ដំណើរការត្រួតពិនិត្យការប្រគល់រថយន្ត ពិនិត្យស្ថានភាព ទូទាត់ប្រាក់នៅសល់ និងកត់ត្រាបំណុល។',
    },
    'search_returns': {
      AppLanguage.english: 'Search returns by vehicle, plate, customer, phone, or booking ID...',
      AppLanguage.khmer: 'ស្វែងរកការប្រគល់តាមរថយន្ត ផ្លាកលេខ អតិថិជន ឬកូដកក់...',
    },
    'awaiting_return': {
      AppLanguage.english: 'Awaiting Return',
      AppLanguage.khmer: 'រង់ចាំប្រគល់រថយន្ត',
    },
    'all_returns': {
      AppLanguage.english: 'All Out on Rent',
      AppLanguage.khmer: 'រថយន្តកំពុងជួលទាំងអស់',
    },
    'overdue_only': {
      AppLanguage.english: 'Overdue / Expired Due',
      AppLanguage.khmer: 'ហួសកាលកំណត់',
    },
    'unpaid_only': {
      AppLanguage.english: 'Unpaid Balance Due',
      AppLanguage.khmer: 'នៅសល់ប្រាក់ជំពាក់',
    },
    'returned_history': {
      AppLanguage.english: 'Return History',
      AppLanguage.khmer: 'ប្រវត្តិប្រគល់រួច',
    },
    'no_returns_matching': {
      AppLanguage.english: 'No vehicles awaiting return match your search or filter.',
      AppLanguage.khmer: 'មិនមានរថយន្តរង់ចាំការប្រគល់ដែលត្រូវគ្នានឹងតម្រងនេះទេ។',
    },
    'check_in_and_return': {
      AppLanguage.english: 'Check-In & Return Car',
      AppLanguage.khmer: 'ត្រួតពិនិត្យ & ប្រគល់រថយន្ត',
    },
    'quick_return_action': {
      AppLanguage.english: 'Process Car Return',
      AppLanguage.khmer: 'ដំណើរការប្រគល់រថយន្ត',
    },
    'overdue_banner_alert': {
      AppLanguage.english: 'Vehicle Overdue Attention Required',
      AppLanguage.khmer: 'ការយកចិត្តទុកដាក់: រថយន្តហួសកាលកំណត់',
    },
    'overdue_banner_desc': {
      AppLanguage.english: 'rental contract(s) have passed their scheduled return date. Immediate check-in or contact required.',
      AppLanguage.khmer: 'កិច្ចសន្យាបានផុតកាលបរិច្ឆេទប្រគល់រថយន្ត។ សូមទាក់ទង ឬត្រួតពិនិត្យជាបន្ទាន់។',
    },
    'payments': {
      AppLanguage.english: 'Payments',
      AppLanguage.khmer: 'ការទូទាត់ប្រាក់',
    },
    'back_to_storefront': {
      AppLanguage.english: 'Back to Storefront',
      AppLanguage.khmer: 'ត្រឡប់ទៅទំព័រមុខ',
    },
    'post_new_banner': {
      AppLanguage.english: 'Post New Hero Banner',
      AppLanguage.khmer: 'បន្ថែមផ្ទាំងផ្សាយថ្មី',
    },
    'add_category': {
      AppLanguage.english: 'Add Category',
      AppLanguage.khmer: 'បន្ថែមប្រភេទថ្មី',
    },
    'add_customer': {
      AppLanguage.english: 'Add Customer',
      AppLanguage.khmer: 'បន្ថែមអតិថិជន',
    },
    'edit_customer': {
      AppLanguage.english: 'Edit Customer',
      AppLanguage.khmer: 'កែសម្រួលអតិថិជន',
    },
    'delete_customer': {
      AppLanguage.english: 'Delete Customer',
      AppLanguage.khmer: 'លុបអតិថិជន',
    },
    'customer_details': {
      AppLanguage.english: 'Customer Profile & History',
      AppLanguage.khmer: 'ប្រវត្តិរូបអតិថិជន & ការកក់',
    },
    'driver_license': {
      AppLanguage.english: "Driver's License / ID",
      AppLanguage.khmer: 'ប័ណ្ណបើកបរ / អត្តសញ្ញាណប័ណ្ណ',
    },
    'customer_address': {
      AppLanguage.english: 'Address / Location',
      AppLanguage.khmer: 'អាសយដ្ឋាន / ទីតាំង',
    },
    'customer_notes': {
      AppLanguage.english: 'Notes / Remarks',
      AppLanguage.khmer: 'កំណត់ចំណាំផ្សេងៗ',
    },
    'total_customers': {
      AppLanguage.english: 'Total Customers',
      AppLanguage.khmer: 'អតិថិជនសរុប',
    },
    'active_renters': {
      AppLanguage.english: 'Active Renters',
      AppLanguage.khmer: 'កំពុងជួលរថយន្ត',
    },
    'total_spent': {
      AppLanguage.english: 'Total Spent',
      AppLanguage.khmer: 'ចំណាយសរុប',
    },
    'customer_saved': {
      AppLanguage.english: 'Customer saved successfully',
      AppLanguage.khmer: 'បានរក្សាទុកព័ត៌មានអតិថិជនដោយជោគជ័យ',
    },
    'customer_deleted': {
      AppLanguage.english: 'Customer deleted successfully',
      AppLanguage.khmer: 'បានលុបអតិថិជនដោយជោគជ័យ',
    },
    'confirm_delete_customer': {
      AppLanguage.english: 'Are you sure you want to delete this customer? This action cannot be undone.',
      AppLanguage.khmer: 'តើអ្នកពិតជាចង់លុបអតិថិជននេះមែនទេ? សកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។',
    },
    'cannot_delete_active_customer': {
      AppLanguage.english: 'Cannot delete customer with active rentals.',
      AppLanguage.khmer: 'មិនអាចលុបអតិថិជនដែលមានការជួលកំពុងដំណើរការទេ។',
    },
    'no_customers_found': {
      AppLanguage.english: 'No customers registered yet.',
      AppLanguage.khmer: 'មិនទាន់មានអតិថិជនបានចុះឈ្មោះនៅឡើយទេ។',
    },
    'no_bookings_history': {
      AppLanguage.english: 'No rental records found for this customer.',
      AppLanguage.khmer: 'មិនទាន់មានប្រវត្តិការកក់សម្រាប់អតិថិជននេះនៅឡើយទេ។',
    },
    'search_customers': {
      AppLanguage.english: 'Search customers by name, phone, email...',
      AppLanguage.khmer: 'ស្វែងរកអតិថិជនតាមឈ្មោះ លេខទូរស័ព្ទ អ៊ីមែល...',
    },
    'search_bookings': {
      AppLanguage.english: 'Search by booking ID, customer or vehicle...',
      AppLanguage.khmer: 'ស្វែងរកតាមលេខកូដកក់ ឈ្មោះអតិថិជន ឬរថយន្ត...',
    },
    'total_bookings': {
      AppLanguage.english: 'Total Bookings',
      AppLanguage.khmer: 'ការកក់សរុប',
    },
    'returned_bookings': {
      AppLanguage.english: 'Completed / Returned',
      AppLanguage.khmer: 'បានប្រគល់រួច',
    },
    'revenue_collected': {
      AppLanguage.english: 'Revenue Collected',
      AppLanguage.khmer: 'ចំណូលប្រមូលបាន',
    },
    'outstanding_receivables': {
      AppLanguage.english: 'Receivables Due',
      AppLanguage.khmer: 'ប្រាក់នៅសល់មិនទាន់ទូទាត់',
    },
    'edit_booking': {
      AppLanguage.english: 'Edit Booking',
      AppLanguage.khmer: 'កែប្រែការកក់',
    },
    'delete_booking': {
      AppLanguage.english: 'Delete Booking',
      AppLanguage.khmer: 'លុបការកក់',
    },
    'booking_details': {
      AppLanguage.english: 'Rental Booking Contract',
      AppLanguage.khmer: 'កិច្ចសន្យា & ព័ត៌មានលម្អិតការកក់',
    },
    'booking_saved': {
      AppLanguage.english: 'Booking saved successfully',
      AppLanguage.khmer: 'បានរក្សាទុកការកក់ដោយជោគជ័យ',
    },
    'booking_deleted': {
      AppLanguage.english: 'Booking record deleted',
      AppLanguage.khmer: 'បានលុបកំណត់ត្រាការកក់រួចរាល់',
    },
    'confirm_delete_booking': {
      AppLanguage.english: 'Are you sure you want to delete this booking record? This action cannot be undone.',
      AppLanguage.khmer: 'តើអ្នកពិតជាចង់លុបកំណត់ត្រាការកក់នេះមែនទេ? សកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។',
    },
    'cannot_delete_active_booking': {
      AppLanguage.english: 'Cannot delete an active rental contract. Please return the vehicle first.',
      AppLanguage.khmer: 'មិនអាចលុបកិច្ចសន្យាដែលកំពុងជួលបានទេ។ សូមប្រគល់រថយន្តសិន។',
    },
    'return_vehicle': {
      AppLanguage.english: 'Return Car',
      AppLanguage.khmer: 'ប្រគល់រថយន្ត',
    },
    'confirm_return_vehicle': {
      AppLanguage.english: 'Confirm vehicle check-in and return inspection completed?',
      AppLanguage.khmer: 'បញ្ជាក់ថារថយន្តត្រូវបានទទួលត្រឡប់ និងត្រួតពិនិត្យរួចរាល់?',
    },
    'vehicle_returned_success': {
      AppLanguage.english: 'Vehicle marked as returned successfully',
      AppLanguage.khmer: 'បានកត់ត្រាការប្រគល់រថយន្តដោយជោគជ័យ',
    },
    'record_payment': {
      AppLanguage.english: 'Record Payment',
      AppLanguage.khmer: 'កត់ត្រាការទូទាត់',
    },
    'record_new_payment': {
      AppLanguage.english: '+ Record Payment',
      AppLanguage.khmer: '+ កត់ត្រាការបង់ប្រាក់',
    },
    'payment_recorded_success': {
      AppLanguage.english: 'Payment recorded successfully',
      AppLanguage.khmer: 'បានកត់ត្រាការបង់ប្រាក់ដោយជោគជ័យ',
    },
    'payment_amount': {
      AppLanguage.english: 'Payment Amount (\$)',
      AppLanguage.khmer: 'ចំនួនទឹកប្រាក់បង់ (\$)',
    },
    'payments_ledger': {
      AppLanguage.english: 'Payments & Financial Ledger',
      AppLanguage.khmer: 'ការទូទាត់ប្រាក់ & បញ្ជីទូទាត់',
    },
    'payments_subtitle': {
      AppLanguage.english: 'Track deposits, settle balances, and issue invoices in USD',
      AppLanguage.khmer: 'កត់ត្រា តាមដាន និងគ្រប់គ្រងការបង់ប្រាក់ និងវិក្កយបត្រ',
    },
    'total_billed': {
      AppLanguage.english: 'Total Billed',
      AppLanguage.khmer: 'ទឹកប្រាក់សរុប',
    },
    'total_collected': {
      AppLanguage.english: 'Total Collected',
      AppLanguage.khmer: 'ប្រាក់បានទូទាត់',
    },
    'total_receivables': {
      AppLanguage.english: 'Balance Due',
      AppLanguage.khmer: 'ប្រាក់នៅសល់មិនទាន់បង់',
    },
    'fully_paid': {
      AppLanguage.english: 'Fully Paid',
      AppLanguage.khmer: 'ទូទាត់រួចរាល់',
    },
    'partial_payment': {
      AppLanguage.english: 'Partial Payment',
      AppLanguage.khmer: 'ទូទាត់ខ្លះ',
    },
    'unpaid': {
      AppLanguage.english: 'Unpaid',
      AppLanguage.khmer: 'មិនទាន់ទូទាត់',
    },
    'payment_notes': {
      AppLanguage.english: 'Payment Notes / Ref #',
      AppLanguage.khmer: 'កំណត់សម្គាល់ការទូទាត់ / លេខយោង',
    },
    'receipt_invoice': {
      AppLanguage.english: 'Official Receipt & Invoice',
      AppLanguage.khmer: 'វិក្កយបត្រ & បង្កាន់ដៃទទួលប្រាក់',
    },
    'receipt_no': {
      AppLanguage.english: 'Receipt #',
      AppLanguage.khmer: 'លេខបង្កាន់ដៃ',
    },
    'payment_date': {
      AppLanguage.english: 'Payment Date',
      AppLanguage.khmer: 'កាលបរិច្ឆេទបង់ប្រាក់',
    },
    'mark_as_paid': {
      AppLanguage.english: 'Mark as Fully Paid',
      AppLanguage.khmer: 'សម្គាល់ថាបានទូទាត់ពេញ',
    },
    'reset_payment': {
      AppLanguage.english: 'Refund / Reset Payment',
      AppLanguage.khmer: 'សងប្រាក់វិញ / កំណត់ជា \$0',
    },
    'confirm_reset_payment': {
      AppLanguage.english: 'Are you sure you want to reset recorded payments to \$0? This will restore the full balance due.',
      AppLanguage.khmer: 'តើអ្នកចង់កំណត់ចំនួនទឹកប្រាក់ដែលបានបង់ឡើងវិញជា \$0 មែនទេ? វានឹងស្តារសមតុល្យត្រូវបង់ពេញលេញឡើងវិញ។',
    },
    'payment_updated_success': {
      AppLanguage.english: 'Payment record updated successfully',
      AppLanguage.khmer: 'បានធ្វើបច្ចុប្បន្នភាពការទូទាត់ដោយជោគជ័យ',
    },
    'pay_full_balance': {
      AppLanguage.english: 'Pay Full Balance',
      AppLanguage.khmer: 'បង់បង្គ្រប់សមតុល្យ',
    },
    'quick_pay': {
      AppLanguage.english: 'Quick Pay',
      AppLanguage.khmer: 'បង់ប្រាក់រហ័ស',
    },
    'amount_to_pay': {
      AppLanguage.english: 'Amount to Pay (\$)',
      AppLanguage.khmer: 'ចំនួនទឹកប្រាក់ត្រូវបង់ (\$)',
    },
    'no_payments_found': {
      AppLanguage.english: 'No payment records match your filters.',
      AppLanguage.khmer: 'រកមិនឃើញកំណត់ត្រាទូទាត់ប្រាក់ត្រូវគ្នានឹងតម្រងរបស់អ្នកទេ។',
    },
    'filter_all': {
      AppLanguage.english: 'All',
      AppLanguage.khmer: 'ទាំងអស់',
    },
    'filter_paid': {
      AppLanguage.english: 'Paid',
      AppLanguage.khmer: 'ទូទាត់រួច',
    },
    'filter_partial': {
      AppLanguage.english: 'Partial',
      AppLanguage.khmer: 'ទូទាត់ខ្លះ',
    },
    'filter_unpaid': {
      AppLanguage.english: 'Unpaid',
      AppLanguage.khmer: 'មិនទាន់បង់',
    },
    'search_payments': {
      AppLanguage.english: 'Search by customer, booking ID, car, phone...',
      AppLanguage.khmer: 'ស្វែងរកតាមឈ្មោះ កូដកក់ រថយន្ត ឬលេខទូរស័ព្ទ...',
    },
    'no_bookings_found': {
      AppLanguage.english: 'No reservations match your filters.',
      AppLanguage.khmer: 'រកមិនឃើញការកក់ត្រូវគ្នានឹងតម្រងរបស់អ្នកទេ។',
    },
    'rental_period': {
      AppLanguage.english: 'Rental Period',
      AppLanguage.khmer: 'រយៈពេលជួល',
    },
    'financial_summary': {
      AppLanguage.english: 'Financial Summary',
      AppLanguage.khmer: 'សង្ខេបហិរញ្ញវត្ថុ',
    },
    'paid_deposit': {
      AppLanguage.english: 'Paid / Deposit',
      AppLanguage.khmer: 'បានបង់ / ប្រាក់កក់',
    },
    'select_vehicle': {
      AppLanguage.english: 'Select Vehicle',
      AppLanguage.khmer: 'ជ្រើសរើសរថយន្ត',
    },
    'select_customer': {
      AppLanguage.english: 'Select Customer',
      AppLanguage.khmer: 'ជ្រើសរើសអតិថិជន',
    },
    'new_booking': {
      AppLanguage.english: 'New Booking',
      AppLanguage.khmer: 'ការកក់ថ្មី',
    },
    'view_all_cars': {
      AppLanguage.english: 'View All Cars',
      AppLanguage.khmer: 'មើលរថយន្តទាំងអស់',
    },
    'popular_cars': {
      AppLanguage.english: 'Popular Cars for You',
      AppLanguage.khmer: 'រថយន្តពេញនិយមសម្រាប់អ្នក',
    },
    'featured_cars': {
      AppLanguage.english: 'FEATURED CARS',
      AppLanguage.khmer: 'រថយន្តពិសេស',
    },
    'show_all_cars': {
      AppLanguage.english: 'Show All Cars',
      AppLanguage.khmer: 'បង្ហាញរថយន្តទាំងអស់',
    },
    'drive_your_dream': {
      AppLanguage.english: 'DRIVE YOUR DREAM',
      AppLanguage.khmer: 'បើកបរបរថយន្តក្នុងក្តីស្រមៃ',
    },
    'hero_title': {
      AppLanguage.english: 'Premium Cars\nfor a Better Tomorrow',
      AppLanguage.khmer: 'រថយន្តប្រណិតទំនើប\nសម្រាប់អនាគតកាន់តែប្រសើរ',
    },
    'hero_subtitle': {
      AppLanguage.english: 'Find the perfect car that matches your lifestyle, budget and journey. We bring you the best deals, top brands and a seamless buying experience.',
      AppLanguage.khmer: 'ស្វែងរករថយន្តដ៏ល្អឥតខ្ចោះដែលស័ក្តិសមនឹងរបៀបរស់នៅ ថវិកា និងដំណើររបស់អ្នក។ យើងនាំមកជូននូវកិច្ចព្រមព្រៀងដ៏ល្អបំផុត ម៉ាកល្បីៗ និងបទពិសោធន៍កក់ដ៏ងាយស្រួល។',
    },
    'explore_collection': {
      AppLanguage.english: 'Explore Collection',
      AppLanguage.khmer: 'ស្វែងរកការប្រមូលផ្តុំ',
    },
    'schedule_test_drive': {
      AppLanguage.english: 'Reserve Rental Handover',
      AppLanguage.khmer: 'កក់ការជួលរថយន្ត',
    },
    'send_message': {
      AppLanguage.english: 'Send Reservation Inquiry',
      AppLanguage.khmer: 'ផ្ញើសំណើកក់រថយន្ត',
    },
    'message_optional': {
      AppLanguage.english: 'Rental Notes / Special Requests (Optional)',
      AppLanguage.khmer: 'កំណត់ចំណាំ ឬសំណើពិសេស (ជម្រើស)',
    },
    'test_drive_sent': {
      AppLanguage.english: 'Rental Reservation Request Sent!',
      AppLanguage.khmer: 'សំណើកក់រថយន្តត្រូវបានផ្ញើជោគជ័យ!',
    },
    'thank_you_contact': {
      AppLanguage.english: 'Thank you! Our rental concierge will contact you shortly to confirm your booking dates, vehicle handover, and reservation details.',
      AppLanguage.khmer: 'សូមអរគុណ! ក្រុមការងារសេវាជួលរថយន្តរបស់យើងនឹងទាក់ទងលោកអ្នកក្នុងពេលឆាប់ៗ ដើម្បីបញ្ជាក់កាលបរិច្ឆេទ ការប្រគល់រថយន្ត និងព័ត៌មានលម្អិត។',
    },
    'all_rights_reserved': {
      AppLanguage.english: 'All Rights Reserved.',
      AppLanguage.khmer: 'រក្សាសិទ្ធិគ្រប់យ៉ាង។',
    },
    'top_tier_fleet': {
      AppLanguage.english: 'Top Tier Fleet',
      AppLanguage.khmer: 'កងរថយន្តលំដាប់កំពូល',
    },
    'fully_insured': {
      AppLanguage.english: '100% Insured Vehicles',
      AppLanguage.khmer: 'រថយន្តមានធានារ៉ាប់រង 100%',
    },
    'vip_support': {
      AppLanguage.english: '24/7 Roadside VIP Support',
      AppLanguage.khmer: 'ជំនួយសង្គ្រោះ 24/7 កម្រិត VIP',
    },
    'best_price': {
      AppLanguage.english: 'Best Rental Rates Guaranteed',
      AppLanguage.khmer: 'ធានាតម្លៃជួលសមរម្យបំផុត',
    },
    'why_choose_us': {
      AppLanguage.english: 'ABOUT US',
      AppLanguage.khmer: 'អំពីយើងខ្ញុំ',
    },
    'trusted_agency': {
      AppLanguage.english: 'Your Trusted Car Rental Agency',
      AppLanguage.khmer: 'ទីភ្នាក់ងារជួលរថយន្តគួរឱ្យទុកចិត្តរបស់អ្នក',
    },
    'our_services': {
      AppLanguage.english: 'OUR RENTAL SERVICES',
      AppLanguage.khmer: 'សេវាកម្មជួលរថយន្តរបស់យើង',
    },
    'services_heading': {
      AppLanguage.english: 'Premium Rental Services We Provide',
      AppLanguage.khmer: 'សេវាកម្មជួលរថយន្តដែលយើងផ្តល់ជូនអ្នក',
    },
    'client_testimonials': {
      AppLanguage.english: 'What Our Customers Say',
      AppLanguage.khmer: 'មតិពីអតិថិជនរបស់យើង',
    },
    'schedule_inquiry': {
      AppLanguage.english: 'RENTAL RESERVATION & CONCIERGE INQUIRY',
      AppLanguage.khmer: 'កក់ការជួលរថយន្ត / ទំនាក់ទំនងសាកសួរ',
    },
    'quick_links': {
      AppLanguage.english: 'Quick Links',
      AppLanguage.khmer: 'តំណភ្ជាប់រហ័ស',
    },
    'contact_info': {
      AppLanguage.english: 'Contact Information',
      AppLanguage.khmer: 'ព័ត៌មានទំនាក់ទំនង',
    },
    'cyber_specs': {
      AppLanguage.english: '3D Specs',
      AppLanguage.khmer: 'លក្ខណៈ 3D',
    },
    'add_to_reservation': {
      AppLanguage.english: 'Add to Reservation',
      AppLanguage.khmer: 'បន្ថែមទៅការកក់',
    },
    'rental_period_schedule': {
      AppLanguage.english: 'Rental Period & Schedule',
      AppLanguage.khmer: 'កាលវិភាគ & រយៈពេលជួល',
    },
    'flexible_cancellation': {
      AppLanguage.english: '100% FLEXIBLE',
      AppLanguage.khmer: 'អាចបត់បែនបាន 100%',
    },
    'quick_duration': {
      AppLanguage.english: 'QUICK DURATION:',
      AppLanguage.khmer: 'រយៈពេលរហ័ស:',
    },
    'confirm_booking': {
      AppLanguage.english: 'Confirm Booking',
      AppLanguage.khmer: 'បញ្ជាក់ការកក់',
    },
    'date_picker_sub': {
      AppLanguage.english: 'Choose your pickup and return dates with free cancellation up to 24h prior',
      AppLanguage.khmer: 'ជ្រើសរើសកាលបរិច្ឆេទទទួល និងប្រគល់រថយន្ត ដោយឥតគិតថ្លៃការលុបចោលមុន 24 ម៉ោង',
    },
    'pickup_date_upper': {
      AppLanguage.english: 'PICKUP DATE',
      AppLanguage.khmer: 'កាលបរិច្ឆេទទទួលរថយន្ត',
    },
    'return_date_upper': {
      AppLanguage.english: 'RETURN DATE',
      AppLanguage.khmer: 'កាលបរិច្ឆេទប្រគល់រថយន្ត',
    },
    'due_date_upper': {
      AppLanguage.english: 'DUE DATE (RETURN)',
      AppLanguage.khmer: 'កាលបរិច្ឆេទប្រគល់រថយន្ត (DUE DATE)',
    },
    'pick_return': {
      AppLanguage.english: 'Pick Return',
      AppLanguage.khmer: 'ជ្រើសរើសថ្ងៃប្រគល់',
    },
    'select_return_date': {
      AppLanguage.english: 'Select Return Date',
      AppLanguage.khmer: 'ជ្រើសរើសកាលបរិច្ឆេទប្រគល់',
    },
    'preset_3_days': {
      AppLanguage.english: '3 Days (Weekend)',
      AppLanguage.khmer: '3 ថ្ងៃ (ចុងសប្តាហ៍)',
    },
    'preset_7_days': {
      AppLanguage.english: '7 Days (1 Week • 10% OFF)',
      AppLanguage.khmer: '7 ថ្ងៃ (1 សប្តាហ៍ • បញ្ចុះ 10%)',
    },
    'preset_14_days': {
      AppLanguage.english: '14 Days (2 Weeks)',
      AppLanguage.khmer: '14 ថ្ងៃ (2 សប្តាហ៍)',
    },
    'preset_30_days': {
      AppLanguage.english: '30 Days (1 Month)',
      AppLanguage.khmer: '30 ថ្ងៃ (1 ខែ)',
    },
    'reset_dates': {
      AppLanguage.english: 'Reset Dates',
      AppLanguage.khmer: 'កំណត់កាលបរិច្ឆេទឡើងវិញ',
    },
    'pickup_selected_msg': {
      AppLanguage.english: 'Pickup date selected. Please tap a return date on the calendar to complete your rental duration.',
      AppLanguage.khmer: 'បានជ្រើសរើសថ្ងៃទទួលរថយន្ត។ សូមចុចលើកាលបរិច្ឆេទប្រគល់ ដើម្បីបញ្ចប់ការកំណត់រយៈពេលជួល។',
    },
    'performance_specs': {
      AppLanguage.english: 'Performance Specifications',
      AppLanguage.khmer: 'លក្ខណៈបច្ចេកទេសដំណើរការ',
    },
    'vehicle_attributes': {
      AppLanguage.english: 'Vehicle Attributes',
      AppLanguage.khmer: 'លក្ខណៈសម្បត្តិរថយន្ត',
    },
    'design_tech_highlights': {
      AppLanguage.english: 'Design & Tech Highlights',
      AppLanguage.khmer: 'ចំណុចលេចធ្លោនៃការរចនា & បច្ចេកវិទ្យា',
    },
    'rental_guarantees': {
      AppLanguage.english: 'Rental Guarantees',
      AppLanguage.khmer: 'ការធានាក្នុងការជួល',
    },
    'full_insurance_desc': {
      AppLanguage.english: 'Full Collision Insurance & 24/7 Roadside Assistance',
      AppLanguage.khmer: 'ធានារ៉ាប់រងការប៉ះទង្គិចពេញលេញ & ជំនួយសង្គ្រោះ 24/7',
    },
    'sanitized_inspection': {
      AppLanguage.english: '100% Sanitized Multi-Point Safety Inspection',
      AppLanguage.khmer: 'អនាម័យ 100% & ត្រួតពិនិត្យសុវត្ថិភាពច្រើនចំណុច',
    },
    'free_vip_delivery': {
      AppLanguage.english: 'Free VIP Airport & Hotel Delivery upon booking',
      AppLanguage.khmer: 'ដឹកជញ្ជូនឥតគិតថ្លៃកម្រិត VIP ទៅកាន់ព្រលានយន្តហោះ & សណ្ឋាគារ',
    },
    'in_reservation_cart': {
      AppLanguage.english: 'In Reservation Cart',
      AppLanguage.khmer: 'ក្នុងកន្ត្រកកក់ទុក',
    },
    'studio_view_360': {
      AppLanguage.english: '360° STUDIO VIEW',
      AppLanguage.khmer: 'ទិដ្ឋភាពស្ទូឌីយោ 360°',
    },
    'browse_cars': {
      AppLanguage.english: 'Browse Our Cars',
      AppLanguage.khmer: 'ស្វែងរករថយន្តរបស់យើង',
    },
    'trip_dates': {
      AppLanguage.english: 'Trip Dates',
      AppLanguage.khmer: 'កាលបរិច្ឆេទធ្វើដំណើរ',
    },
    'trusted_dealership': {
      AppLanguage.english: 'Verified Rental Fleet',
      AppLanguage.khmer: 'កងរថយន្តជួលមានទំនុកចិត្ត',
    },
    'genuine_verified': {
      AppLanguage.english: '100% Insured & Inspected Fleet',
      AppLanguage.khmer: 'រថយន្តត្រួតពិនិត្យ & ធានារ៉ាប់រង 100%',
    },
    'best_prices': {
      AppLanguage.english: 'Best Rental Rates',
      AppLanguage.khmer: 'តម្លៃជួលសមរម្យបំផុត',
    },
    'competitive_rates': {
      AppLanguage.english: 'Transparent Daily & Monthly Rates',
      AppLanguage.khmer: 'តម្លៃជួលប្រចាំថ្ងៃ និងខែច្បាស់លាស់',
    },
    'expert_support': {
      AppLanguage.english: '24/7 Roadside Assistance',
      AppLanguage.khmer: 'ជំនួយសង្គ្រោះលើផ្លូវ ២៤/៧',
    },
    'always_here_to_help': {
      AppLanguage.english: 'Emergency Support Across Cambodia',
      AppLanguage.khmer: 'នៅក្បែរអ្នកគ្រប់ពេលធ្វើដំណើរ',
    },
    'easy_trade_in': {
      AppLanguage.english: 'Airport & Hotel Delivery',
      AppLanguage.khmer: 'សេវាប្រគល់រថយន្តដល់ទីកន្លែង',
    },
    'upgrade_confidence': {
      AppLanguage.english: 'Punctual Doorstep Handover',
      AppLanguage.khmer: 'ប្រគល់ជូនដល់ព្រលាន និងសណ្ឋាគារ',
    },
    'learn_more': {
      AppLanguage.english: 'Learn More',
      AppLanguage.khmer: 'ស្វែងយល់បន្ថែម',
    },
    'purchase_price': {
      AppLanguage.english: 'Security Deposit',
      AppLanguage.khmer: 'ប្រាក់កក់ធានា',
    },
    'security_deposit': {
      AppLanguage.english: 'Security Deposit',
      AppLanguage.khmer: 'ប្រាក់កក់ធានា',
    },
    'daily_lease': {
      AppLanguage.english: 'Daily Rental Rate',
      AppLanguage.khmer: 'តម្លៃជួលប្រចាំថ្ងៃ',
    },
    'more_than_cars': {
      AppLanguage.english: 'More Than Just Cars,',
      AppLanguage.khmer: 'លើសពីរថយន្តធម្មតា,',
    },
    'we_build_trust': {
      AppLanguage.english: 'We Build Trust',
      AppLanguage.khmer: 'យើងកសាងទំនុកចិត្ត',
    },
    'about_intro': {
      AppLanguage.english: 'At DriveLine Car Rental, we believe that renting a premium vehicle is more than just a ride — it\'s the freedom and peace of mind for your journey. With years of experience in vehicle rental management, we provide pristine, fully insured vehicles, transparent rental rates, and exceptional concierge service. Your journey drives us forward.',
      AppLanguage.khmer: 'នៅទីភ្នាក់ងារជួលរថយន្ត DriveLine យើងជឿជាក់ថាការជួលរថយន្តប្រណិតគឺលើសពីការធ្វើដំណើរ — វាជាសេរីភាព និងទំនុកចិត្តពេញលេញក្នុងដំណើរកម្សាន្ត និងការងាររបស់អ្នក។ យើងប្តេជ្ញាផ្តល់ជូននូវរថយន្តស្អាត ធានារ៉ាប់រងពេញលេញ តម្លៃជួលច្បាស់លាស់ និងសេវាកម្មថែទាំអតិថិជនកម្រិតខ្ពស់។',
    },
    'about_bullet_1': {
      AppLanguage.english: 'Diverse Fleet: SUV, Sedan, Luxury & Van',
      AppLanguage.khmer: 'កងរថយន្តជួលចម្រុះ: SUV, Sedan, ប្រណិត & Van',
    },
    'about_bullet_2': {
      AppLanguage.english: 'Transparent & Zero-Hidden-Fee Contracts',
      AppLanguage.khmer: 'កិច្ចសន្យាតម្លាភាព គ្មានការគិតថ្លៃលាក់កំបាំង',
    },
    'about_bullet_3': {
      AppLanguage.english: 'Professional Chauffeur & Self-Drive Options',
      AppLanguage.khmer: 'ជម្រើសបើកបរខ្លួនឯង ឬជាមួយអ្នកបើកបរកម្រិត VIP',
    },
    'about_bullet_4': {
      AppLanguage.english: '24/7 Roadside & On-Trip Support',
      AppLanguage.khmer: 'សេវាសង្គ្រោះ & គាំទ្រការធ្វើដំណើរ ២៤/៧',
    },
    'active_banners_label': {
      AppLanguage.english: 'ACTIVE BANNERS • AUTO ROTATING',
      AppLanguage.khmer: 'ផ្ទាំងផ្សាយសកម្ម • បង្វិលស្វ័យប្រវត្តិ',
    },
    'exclusive_offer': {
      AppLanguage.english: 'Exclusive Special Offer',
      AppLanguage.khmer: 'ការផ្តល់ជូនពិសេសផ្តាច់មុខ',
    },
    'explore_cars': {
      AppLanguage.english: 'Explore Cars',
      AppLanguage.khmer: 'ស្វែងរករថយន្ត',
    },
    'book_drive': {
      AppLanguage.english: 'Book Drive',
      AppLanguage.khmer: 'កក់បើកបរ',
    },
    'reserve_online': {
      AppLanguage.english: 'Reserve Online',
      AppLanguage.khmer: 'កក់ទុកអនឡាញ',
    },
    'available_for_booking': {
      AppLanguage.english: 'Available for Booking',
      AppLanguage.khmer: 'ទំនេរសម្រាប់កក់',
    },
    'flagship_luxury': {
      AppLanguage.english: 'FLAGSHIP PERFORMANCE & LUXURY',
      AppLanguage.khmer: 'ដំណើរការលំដាប់កំពូល & ប្រណិតភាព',
    },
    'engine_upper': {
      AppLanguage.english: 'ENGINE',
      AppLanguage.khmer: 'ម៉ាស៊ីន',
    },
    'power_upper': {
      AppLanguage.english: 'POWER',
      AppLanguage.khmer: 'កម្លាំង',
    },
    'speed_upper': {
      AppLanguage.english: 'TOP SPEED',
      AppLanguage.khmer: 'ល្បឿនអតិបរមា',
    },
    'accel_upper': {
      AppLanguage.english: '0-100 ACCEL',
      AppLanguage.khmer: 'សន្ទុះ 0-100',
    },
    'year_prefix': {
      AppLanguage.english: 'Year',
      AppLanguage.khmer: 'ឆ្នាំ',
    },
    'msrp': {
      AppLanguage.english: 'Security Deposit',
      AppLanguage.khmer: 'ប្រាក់កក់ធានា',
    },
    'day': {
      AppLanguage.english: 'Day',
      AppLanguage.khmer: 'ថ្ងៃ',
    },
    'dates': {
      AppLanguage.english: 'Dates',
      AppLanguage.khmer: 'កាលបរិច្ឆេទ',
    },
    'booked': {
      AppLanguage.english: 'Booked',
      AppLanguage.khmer: 'បានកក់រួច',
    },
    'executive_dashboard': {
      AppLanguage.english: 'Executive Fleet Dashboard',
      AppLanguage.khmer: 'ផ្ទាំងគ្រប់គ្រងកងរថយន្តប្រតិបត្តិ',
    },
    'executive_telemetry': {
      AppLanguage.english: 'Real-time telemetry and fleet commercial metrics',
      AppLanguage.khmer: 'ទិន្នន័យជាក់ស្តែង និងសូចនាករពាណិជ្ជកម្មកងរថយន្ត',
    },
    'brand_breakdown_title': {
      AppLanguage.english: 'Brand Performance Matrix',
      AppLanguage.khmer: 'តារាងវិភាគតាមម៉ាករថយន្ត',
    },
    'brand_breakdown_subtitle': {
      AppLanguage.english: 'Fleet distribution, asset valuation and utilization across vehicle brands',
      AppLanguage.khmer: 'ការបែងចែកកងរថយន្ត តម្លៃទ្រព្យសកម្ម និងអត្រាប្រើប្រាស់តាមម៉ាកនីមួយៗ',
    },
    'category_analytics_title': {
      AppLanguage.english: 'Category Distribution & Analytics',
      AppLanguage.khmer: 'ការវិភាគ និងចែកចាយតាមប្រភេទរថយន្ត',
    },
    'category_analytics_subtitle': {
      AppLanguage.english: 'Inventory breakdown by vehicle classification, pricing and availability',
      AppLanguage.khmer: 'ការបែងចែកសារពើភ័ណ្ឌតាមចំណាត់ថ្នាក់រថយន្ត តម្លៃ និងភាពទំនេរ',
    },
    'brand': {
      AppLanguage.english: 'Brand',
      AppLanguage.khmer: 'ម៉ាករថយន្ត',
    },
    'total_fleet': {
      AppLanguage.english: 'Total Fleet',
      AppLanguage.khmer: 'រថយន្តសរុប',
    },
    'available_count': {
      AppLanguage.english: 'Available',
      AppLanguage.khmer: 'ទំនេរ/អាចជួលបាន',
    },
    'rented_count': {
      AppLanguage.english: 'Rented / Active',
      AppLanguage.khmer: 'កំពុងជួល',
    },
    'maintenance_count': {
      AppLanguage.english: 'Maintenance',
      AppLanguage.khmer: 'កំពុងថែទាំ',
    },
    'utilization': {
      AppLanguage.english: 'Utilization',
      AppLanguage.khmer: 'អត្រាប្រើប្រាស់',
    },
    'asset_valuation': {
      AppLanguage.english: 'Asset Valuation',
      AppLanguage.khmer: 'តម្លៃទ្រព្យសកម្ម',
    },
    'rate_range': {
      AppLanguage.english: 'Daily Rate Range',
      AppLanguage.khmer: 'កម្រិតតម្លៃប្រចាំថ្ងៃ',
    },
    'action': {
      AppLanguage.english: 'Action',
      AppLanguage.khmer: 'សកម្មភាព',
    },
    'view_brand_fleet': {
      AppLanguage.english: 'View Fleet',
      AppLanguage.khmer: 'មើលរថយន្ត',
    },
    'filter_brand': {
      AppLanguage.english: 'Filter Brand',
      AppLanguage.khmer: 'ជ្រើសរើសម៉ាកនេះ',
    },
    'all_brands': {
      AppLanguage.english: 'All Brands',
      AppLanguage.khmer: 'ម៉ាកទាំងអស់',
    },
    'all_categories': {
      AppLanguage.english: 'All Categories',
      AppLanguage.khmer: 'ប្រភេទទាំងអស់',
    },
    'category_name': {
      AppLanguage.english: 'Category',
      AppLanguage.khmer: 'ប្រភេទ',
    },
    'status_filter': {
      AppLanguage.english: 'Status',
      AppLanguage.khmer: 'ស្ថានភាព',
    },
    'all_status': {
      AppLanguage.english: 'All Status',
      AppLanguage.khmer: 'ស្ថានភាពទាំងអស់',
    },
    'status_available': {
      AppLanguage.english: 'Available',
      AppLanguage.khmer: 'ទំនេរ',
    },
    'status_rented': {
      AppLanguage.english: 'Rented',
      AppLanguage.khmer: 'កំពុងជួល',
    },
    'status_maintenance': {
      AppLanguage.english: 'Maintenance',
      AppLanguage.khmer: 'ថែទាំ',
    },
    'reset_filters': {
      AppLanguage.english: 'Reset Filters',
      AppLanguage.khmer: 'កំណត់តម្រងឡើងវិញ',
    },
    'quick_operations': {
      AppLanguage.english: 'Quick Operations',
      AppLanguage.khmer: 'ប្រតិបត្តិការរហ័ស',
    },
    'quick_operations_sub': {
      AppLanguage.english: 'Post new fleet products, configure hero banners, or create reservations',
      AppLanguage.khmer: 'បន្ថែមរថយន្តថ្មី កំណត់ផ្ទាំងផ្សាយពាណិជ្ជកម្ម ឬបង្កើតការកក់ថ្មី',
    },
    'inventory_summary': {
      AppLanguage.english: 'Total Inventory Value',
      AppLanguage.khmer: 'តម្លៃសរុបសារពើភ័ណ្ឌ',
    },
    'banner_hero_badge': {
      AppLanguage.english: 'ACTIVE HERO BANNER',
      AppLanguage.khmer: 'ផ្ទាំងផ្សាយសកម្ម',
    },
    'edit_product': {
      AppLanguage.english: 'Edit Product Specs',
      AppLanguage.khmer: 'កែប្រែលក្ខណៈរថយន្ត',
    },
    'feature_on_banner': {
      AppLanguage.english: 'Promote to Banner',
      AppLanguage.khmer: 'ផ្សាយលើផ្ទាំងធំ',
    },
    'mark_maintenance': {
      AppLanguage.english: 'Mark Maintenance',
      AppLanguage.khmer: 'ដាក់ជួសជុលថែទាំ',
    },
    'mark_ready': {
      AppLanguage.english: 'Mark Ready / Available',
      AppLanguage.khmer: 'ដាក់ឱ្យដំណើរការឡើងវិញ',
    },
    'delete_product': {
      AppLanguage.english: 'Delete Vehicle',
      AppLanguage.khmer: 'លុបរថយន្ត',
    },
    'new_fleet_product': {
      AppLanguage.english: 'Post New Fleet Product',
      AppLanguage.khmer: 'បន្ថែមផលិតផលរថយន្តថ្មី',
    },
    'avg_rate': {
      AppLanguage.english: 'Avg Rate',
      AppLanguage.khmer: 'តម្លៃមធ្យម',
    },
    'available_fleet': {
      AppLanguage.english: 'Available Fleet',
      AppLanguage.khmer: 'រថយន្តទំនេរ',
    },
    'active_banners': {
      AppLanguage.english: 'Active Banners',
      AppLanguage.khmer: 'ផ្ទាំងផ្សាយសកម្ម',
    },
    'active_rentals': {
      AppLanguage.english: 'Active Rentals',
      AppLanguage.khmer: 'ការជួលកំពុងដំណើរការ',
    },
    'active_fleet_kpi': {
      AppLanguage.english: 'Active Fleet Ratio',
      AppLanguage.khmer: 'សមាមាត្រកងរថយន្តសកម្ម',
    },
    'revenue_collected_kpi': {
      AppLanguage.english: 'Collected Revenue',
      AppLanguage.khmer: 'ចំណូលទទួលបាន',
    },
    'pending_balance_kpi': {
      AppLanguage.english: 'Pending Receivables',
      AppLanguage.khmer: 'ទឹកប្រាក់នៅសល់',
    },
    'search_fleet_hint': {
      AppLanguage.english: 'Search fleet by model, brand, plate or specs...',
      AppLanguage.khmer: 'ស្វែងរករថយន្តតាមឈ្មោះ ម៉ាក ផ្លាកលេខ ឬលក្ខណៈ...',
    },
    'no_brand_match': {
      AppLanguage.english: 'No vehicle brands found.',
      AppLanguage.khmer: 'មិនមានម៉ាករថយន្តត្រូវបានរកឃើញទេ។',
    },
    'categories_covered': {
      AppLanguage.english: 'Categories',
      AppLanguage.khmer: 'ប្រភេទរថយន្ត',
    },
    'payment_method': {
      AppLanguage.english: 'Payment Method & Terms',
      AppLanguage.khmer: 'វិធីសាស្ត្រទូទាត់ប្រាក់ & លក្ខខណ្ឌ',
    },
    'pay_in_full': {
      AppLanguage.english: 'Pay in Full (100%)',
      AppLanguage.khmer: 'ទូទាត់ពេញលេញ (100%)',
    },
    'pay_deposit': {
      AppLanguage.english: 'Pay 30% Deposit',
      AppLanguage.khmer: 'បង់ប្រាក់កក់ 30%',
    },
    'pay_at_pickup': {
      AppLanguage.english: 'Pay at Pickup (Cash / Card)',
      AppLanguage.khmer: 'ទូទាត់ពេលទទួលរថយន្ត (ប្រាក់សុទ្ធ / កាត)',
    },
    'credit_card': {
      AppLanguage.english: 'Credit / Debit Card',
      AppLanguage.khmer: 'កាតឥណទាន / ឥណពន្ធ',
    },
    'khqr_aba': {
      AppLanguage.english: 'ABA / KHQR Mobile Banking',
      AppLanguage.khmer: 'ស្កេនទូទាត់តាម KHQR / ABA',
    },
    'cash_on_arrival': {
      AppLanguage.english: 'Cash on Arrival',
      AppLanguage.khmer: 'បង់ប្រាក់សុទ្ធពេលទទួលរថយន្ត',
    },
    'payment_summary': {
      AppLanguage.english: 'Payment Status & Receipt',
      AppLanguage.khmer: 'ស្ថានភាពទូទាត់ & វិក្កយបត្រ',
    },
    'amount_paid': {
      AppLanguage.english: 'Amount Paid',
      AppLanguage.khmer: 'ទឹកប្រាក់បានទូទាត់',
    },
    'remaining_balance': {
      AppLanguage.english: 'Remaining Balance Due',
      AppLanguage.khmer: 'ទឹកប្រាក់នៅសល់ត្រូវទូទាត់',
    },
    'paid_in_full': {
      AppLanguage.english: 'PAID IN FULL',
      AppLanguage.khmer: 'បានទូទាត់ពេញ 100%',
    },
    'deposit_paid': {
      AppLanguage.english: 'DEPOSIT CONFIRMED (30%)',
      AppLanguage.khmer: 'បានបង់ប្រាក់កក់ 30%',
    },
    'payment_pending': {
      AppLanguage.english: 'PAY ON ARRIVAL',
      AppLanguage.khmer: 'ទូទាត់ពេលមកដល់',
    },
    'card_number': {
      AppLanguage.english: 'Card Number',
      AppLanguage.khmer: 'លេខកាត',
    },
    'card_expiry': {
      AppLanguage.english: 'Expiry (MM/YY)',
      AppLanguage.khmer: 'ថ្ងៃផុតកំណត់ (MM/YY)',
    },
    'card_cvv': {
      AppLanguage.english: 'CVV',
      AppLanguage.khmer: 'លេខកូដ CVV',
    },
    'scan_khqr': {
      AppLanguage.english: 'Scan KHQR with any Banking App (ABA, ACLEDA, Wing...)',
      AppLanguage.khmer: 'ស្កេន KHQR ជាមួយកម្មវិធីធនាគារណាមួយ (ABA, ACLEDA, Wing...)',
    },
    'booking_receipt': {
      AppLanguage.english: 'Reservation Receipt',
      AppLanguage.khmer: 'ប័ណ្ណបញ្ជាក់ការកក់រថយន្ត',
    },
    'view_in_dashboard': {
      AppLanguage.english: 'View in Admin Dashboard',
      AppLanguage.khmer: 'មើលក្នុងផ្ទាំងគ្រប់គ្រងរដ្ឋបាល',
    },
    'book_another_car': {
      AppLanguage.english: 'Book Another Car',
      AppLanguage.khmer: 'កក់រថយន្តបន្ថែម',
    },
    // Showroom Stock & Availability
    'showroom_fleet_stock': {
      AppLanguage.english: 'Showroom Stock & Fleet Status',
      AppLanguage.khmer: 'ស្ថានភាពស្តុក និងកងរថយន្តក្នុងហាង',
    },
    'stock_filter_all': {
      AppLanguage.english: 'All Fleet',
      AppLanguage.khmer: 'រថយន្តទាំងអស់',
    },
    'stock_filter_available': {
      AppLanguage.english: 'Available in Stock',
      AppLanguage.khmer: 'មានក្នុងស្តុក (ទំនេរ)',
    },
    'stock_filter_unavailable': {
      AppLanguage.english: 'Unavailable / Booked',
      AppLanguage.khmer: 'មិនទំនេរ / បានកក់ទុក',
    },
    'stock_badge_available': {
      AppLanguage.english: 'AVAILABLE IN STOCK',
      AppLanguage.khmer: 'មានក្នុងស្តុក (ទំនេរ)',
    },
    'stock_badge_rented': {
      AppLanguage.english: 'CURRENTLY BOOKED',
      AppLanguage.khmer: 'បានកក់ទុក / កំពុងជួល',
    },
    'stock_badge_maintenance': {
      AppLanguage.english: 'IN MAINTENANCE',
      AppLanguage.khmer: 'កំពុងជួសជុលថែទាំ',
    },
    'car_unavailable_dialog_title': {
      AppLanguage.english: 'Vehicle Unavailable for Selected Dates',
      AppLanguage.khmer: 'រថយន្តមិនទំនេរសម្រាប់កាលបរិច្ឆេទនេះទេ',
    },
    'car_unavailable_dialog_desc': {
      AppLanguage.english: 'This vehicle is currently reserved by another customer or scheduled for maintenance during your selected rental period. Please choose alternate dates or explore our other available fleet.',
      AppLanguage.khmer: 'រថយន្តនេះត្រូវបានកក់ទុករួចហើយ ឬកំពុងស្ថិតក្នុងកាលវិភាគថែទាំសម្រាប់អំឡុងពេលដែលលោកអ្នកបានជ្រើសរើស។ សូមផ្លាស់ប្តូរកាលបរិច្ឆេទ ឬជ្រើសរើសរថយន្តផ្សេងទៀតដែលមានក្នុងស្តុក។',
    },
    'adjust_rental_dates': {
      AppLanguage.english: 'Adjust Rental Dates',
      AppLanguage.khmer: 'ផ្លាស់ប្តូរកាលបរិច្ឆេទជួល',
    },
    'explore_available_fleet': {
      AppLanguage.english: 'Show Available Fleet',
      AppLanguage.khmer: 'បង្ហាញរថយន្តទំនេរ',
    },
    'live_stock_summary': {
      AppLanguage.english: 'Live Showroom Stock',
      AppLanguage.khmer: 'ស្តុកផ្ទាល់ក្នុងហាង',
    },
    'return_vehicle_title': {
      AppLanguage.english: 'Return Vehicle & Check-In',
      AppLanguage.khmer: 'ការត្រួតពិនិត្យ & ប្រគល់រថយន្ត',
    },
    'settle_and_return': {
      AppLanguage.english: 'Settle Balance & Return',
      AppLanguage.khmer: 'ទូទាត់ប្រាក់នៅសល់ & ប្រគល់រថយន្ត',
    },
    'return_with_debt': {
      AppLanguage.english: 'Return with Pending Debt',
      AppLanguage.khmer: 'ប្រគល់រថយន្តទុកបំណុល',
    },
    'unpaid_balance_warning': {
      AppLanguage.english: 'Outstanding Balance Due',
      AppLanguage.khmer: 'នៅសល់ប្រាក់ជំពាក់មិនទាន់ទូទាត់',
    },
    'unpaid_debt_notice': {
      AppLanguage.english: 'This rental has an unpaid balance. You can settle the full amount now, or return the vehicle to inventory while retaining the customer\'s debt record.',
      AppLanguage.khmer: 'ការជួលនេះនៅសល់ប្រាក់មិនទាន់ទូទាត់។ អ្នកអាចទូទាត់ពេញឥឡូវនេះ ឬកត់ត្រាការប្រគល់រថយន្តចូលស្តុកដោយរក្សាទុកកំណត់ត្រាបំណុលរបស់អតិថិជន។',
    },
    'rental_overdue_warning': {
      AppLanguage.english: 'Rental Period Expired / Overdue',
      AppLanguage.khmer: 'កាលបរិច្ឆេទជួលបានហួសកំណត់',
    },
    'overdue_days_count': {
      AppLanguage.english: 'Overdue by',
      AppLanguage.khmer: 'ហួសកំណត់ចំនួន',
    },
    'days_unit': {
      AppLanguage.english: 'days',
      AppLanguage.khmer: 'ថ្ងៃ',
    },
    'return_notes': {
      AppLanguage.english: 'Inspection & Return Notes',
      AppLanguage.khmer: 'កំណត់ចំណាំការត្រួតពិនិត្យ និងប្រគល់',
    },
    'return_notes_hint': {
      AppLanguage.english: 'e.g., Full tank fuel, pristine condition, or minor damage notes...',
      AppLanguage.khmer: 'ឧ. សាំងពេញធុង, ស្ថានភាពល្អ ឬកត់ត្រាការខូចខាត...',
    },
    'returned_with_debt_badge': {
      AppLanguage.english: 'Returned (Debt Due)',
      AppLanguage.khmer: 'បានប្រគល់ • នៅសល់ជំពាក់',
    },
    'settle_debt': {
      AppLanguage.english: 'Settle Debt',
      AppLanguage.khmer: 'ទូទាត់បំណុល',
    },
    'full_payment_collected': {
      AppLanguage.english: 'Full balance settled and car returned to showroom inventory.',
      AppLanguage.khmer: 'បានទូទាត់ប្រាក់នៅសល់រួចរាល់ និងបានប្រគល់រថយន្តចូលស្តុកវិញ។',
    },
    'returned_unpaid_success': {
      AppLanguage.english: 'Car returned to inventory. Customer balance recorded as debt due.',
      AppLanguage.khmer: 'បានប្រគល់រថយន្តចូលស្តុកវិញ។ ប្រាក់នៅសល់ត្រូវបានកត់ត្រាជាបំណុលត្រូវទូទាត់។',
    },
    'vehicle_checkin_complete': {
      AppLanguage.english: 'Vehicle check-in completed and returned to fleet.',
      AppLanguage.khmer: 'ការត្រួតពិនិត្យប្រគល់រថយន្តបានបញ្ចប់ និងចូលកងរថយន្តវិញ។',
    },
  };

  static String tr(String key, AppLanguage lang) {
    return _strings[key]?[lang] ?? _strings[key]?[AppLanguage.english] ?? key;
  }
}

