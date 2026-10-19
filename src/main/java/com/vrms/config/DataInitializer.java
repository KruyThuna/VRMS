package com.vrms.config;

import com.vrms.model.AgencyConfig;
import com.vrms.model.BannerItem;
import com.vrms.model.Customer;
import com.vrms.model.Rental;
import com.vrms.model.Vehicle;
import com.vrms.repository.AgencyConfigRepository;
import com.vrms.repository.BannerItemRepository;
import com.vrms.repository.CustomerRepository;
import com.vrms.repository.RentalRepository;
import com.vrms.repository.VehicleRepository;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

import java.time.LocalDate;
import java.util.List;

@Component
public class DataInitializer implements CommandLineRunner {

    private final VehicleRepository vehicleRepository;
    private final BannerItemRepository bannerItemRepository;
    private final CustomerRepository customerRepository;
    private final RentalRepository rentalRepository;
    private final AgencyConfigRepository agencyConfigRepository;

    public DataInitializer(
            VehicleRepository vehicleRepository,
            BannerItemRepository bannerItemRepository,
            CustomerRepository customerRepository,
            RentalRepository rentalRepository,
            AgencyConfigRepository agencyConfigRepository) {
        this.vehicleRepository = vehicleRepository;
        this.bannerItemRepository = bannerItemRepository;
        this.customerRepository = customerRepository;
        this.rentalRepository = rentalRepository;
        this.agencyConfigRepository = agencyConfigRepository;
    }

    @Override
    public void run(String... args) {
        if (vehicleRepository.count() == 0) {
            initVehicles();
        }
        if (bannerItemRepository.count() == 0) {
            initBanners();
        }
        if (customerRepository.count() == 0) {
            initCustomers();
        }
        if (agencyConfigRepository.count() == 0) {
            initAgency();
        }
    }

    private void initVehicles() {
        vehicleRepository.saveAll(List.of(
            Vehicle.builder()
                .id("v_tiggo9")
                .name("Chery Tiggo 9")
                .brand("Chery")
                .type("SUV")
                .dailyCents(5500)
                .purchasePrice(34500)
                .available(true)
                .fuel("Petrol Turbo")
                .seats(7)
                .transmission("8-Speed AT")
                .engine("2.0L TGDI Turbo")
                .horsepower("261 HP")
                .topSpeed("205 KM/H")
                .acceleration("7.5s")
                .imageUrl("assets/images/tiggo9_banner.png")
                .maintenance(false)
                .tagline("ONE STEP AHEAD")
                .year(2025)
                .build(),

            Vehicle.builder()
                .id("v0")
                .name("Bugatti La Voiture Noire")
                .brand("Bugatti")
                .type("Hypercar")
                .dailyCents(95000)
                .purchasePrice(11000000)
                .available(true)
                .fuel("Quad-Turbo W16")
                .seats(2)
                .transmission("7-Speed Dual-Clutch")
                .engine("8.0L W16 Quad-Turbo")
                .horsepower("1500 HP")
                .topSpeed("420 KM/H")
                .acceleration("2.4s")
                .imageUrl("https://images.unsplash.com/photo-1617788138017-80ad40651399?w=1200&q=80")
                .maintenance(false)
                .tagline("THE EXCLUSIVE MASTERPIECE")
                .year(2024)
                .build(),

            Vehicle.builder()
                .id("v1")
                .name("Toyota Fortuner")
                .brand("Toyota")
                .type("SUV")
                .dailyCents(6500)
                .purchasePrice(42000)
                .available(true)
                .fuel("Diesel")
                .seats(7)
                .transmission("Automatic")
                .engine("2.8L Diesel")
                .horsepower("201 HP")
                .topSpeed("180 KM/H")
                .acceleration("9.8s")
                .imageUrl("https://images.unsplash.com/photo-1533473359331-0135ef1b58bf?w=1200&q=80")
                .maintenance(false)
                .tagline("TOUGH & RELIABLE")
                .year(2023)
                .build(),

            Vehicle.builder()
                .id("v2")
                .name("Toyota Land Cruiser")
                .brand("Toyota")
                .type("SUV")
                .dailyCents(9500)
                .purchasePrice(68000)
                .available(false)
                .fuel("Diesel Twin-Turbo")
                .seats(7)
                .transmission("Automatic")
                .engine("3.3L V6 Twin-Turbo")
                .horsepower("304 HP")
                .topSpeed("210 KM/H")
                .acceleration("7.9s")
                .imageUrl("https://images.unsplash.com/photo-1541899481282-d53bffe3c35d?w=1200&q=80")
                .maintenance(false)
                .tagline("KING OF THE ROAD")
                .year(2024)
                .build(),

            Vehicle.builder()
                .id("v3")
                .name("Porsche 911 GT3 RS")
                .brand("Porsche")
                .type("Sports")
                .dailyCents(22000)
                .purchasePrice(225000)
                .available(true)
                .fuel("Premium Gasoline")
                .seats(2)
                .transmission("7-Speed PDK")
                .engine("4.0L Naturally Aspirated Flat-6")
                .horsepower("518 HP")
                .topSpeed("296 KM/H")
                .acceleration("3.0s")
                .imageUrl("https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=1200&q=80")
                .maintenance(false)
                .tagline("TRACK WEAPON")
                .year(2024)
                .build(),

            Vehicle.builder()
                .id("v5")
                .name("Tesla Model 3 AWD")
                .brand("Tesla")
                .type("Electric")
                .dailyCents(7500)
                .purchasePrice(38900)
                .available(true)
                .fuel("Electric Dual Motor")
                .seats(5)
                .transmission("Single-Speed")
                .engine("Dual Electric Motors")
                .horsepower("450 HP")
                .topSpeed("233 KM/H")
                .acceleration("3.1s")
                .imageUrl("https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=1200&q=80")
                .maintenance(false)
                .tagline("THE ELECTRIC REVOLUTION")
                .year(2024)
                .build(),

            Vehicle.builder()
                .id("v6")
                .name("BMW 4 Series Gran Coupe")
                .brand("BMW")
                .type("Luxury")
                .dailyCents(8500)
                .purchasePrice(48000)
                .available(true)
                .fuel("Petrol TwinPower")
                .seats(5)
                .transmission("8-Speed Steptronic")
                .engine("2.0L TwinPower Turbo")
                .horsepower("258 HP")
                .topSpeed("250 KM/H")
                .acceleration("5.8s")
                .imageUrl("https://images.unsplash.com/photo-1555215695-3004980ad54e?w=1200&q=80")
                .maintenance(false)
                .tagline("THE ULTIMATE DRIVING MACHINE")
                .year(2023)
                .build(),

            Vehicle.builder()
                .id("v7")
                .name("Audi RS e-tron GT")
                .brand("Audi")
                .type("Concept")
                .dailyCents(18000)
                .purchasePrice(145000)
                .available(false)
                .fuel("All-Electric Quattro")
                .seats(4)
                .transmission("2-Speed Automatic")
                .engine("Dual Permanent Magnet Motors")
                .horsepower("637 HP")
                .topSpeed("250 KM/H")
                .acceleration("3.1s")
                .imageUrl("https://images.unsplash.com/photo-1614200187524-dc4b892acf16?w=1200&q=80")
                .maintenance(true)
                .tagline("FUTURE IN MOTION")
                .year(2024)
                .build()
        ));
    }

    private void initBanners() {
        bannerItemRepository.saveAll(List.of(
            BannerItem.builder()
                .id("b_tiggo9")
                .tagline("ONE STEP AHEAD")
                .title("TIGGO 9")
                .subtitle("Chery Flagship Luxury 7-Seat Intelligent AWD SUV")
                .vehicleId("v_tiggo9")
                .priceText("$55 / DAY • FULL INSURANCE")
                .imageUrl("assets/images/tiggo9_banner.png")
                .specChips(List.of("2.0L TGDI TURBO · 261 HP", "8-SPEED AT · INTELLIGENT AWD", "CDC SUSPENSION", "7-SEAT LUXURY"))
                .badgeText("CHERY FLAGSHIP")
                .badgeColorValue(0xFF10B981L)
                .active(true)
                .build(),

            BannerItem.builder()
                .id("b_bugatti")
                .tagline("THE EXCLUSIVE MASTERPIECE")
                .title("LA VOITURE NOIRE")
                .subtitle("1-of-1 Bespoke Carbon Hypercar • 1500 HP W16 Quad-Turbo")
                .vehicleId("v0")
                .priceText("$950 / DAY • VIP CHAUFFEUR & INSURANCE")
                .imageUrl("https://images.unsplash.com/photo-1617788138017-80ad40651399?w=1200&q=80")
                .specChips(List.of("8.0L W16 QUAD-TURBO · 1500 CV", "0-100 IN 2.5 SEC · 420 KM/H", "FULL CARBON MONOCOQUE", "1 OF 1 WORLDWIDE"))
                .badgeText("HYPERCAR ICON")
                .badgeColorValue(0xFFE50914L)
                .active(true)
                .build(),

            BannerItem.builder()
                .id("b_tesla")
                .tagline("THE ELECTRIC REVOLUTION")
                .title("MODEL 3 AWD")
                .subtitle("Instant Torque Dual Motor • Autopilot Enabled Cockpit")
                .vehicleId("v5")
                .priceText("$75 / DAY • FREE CHARGING & GPS")
                .imageUrl("https://images.unsplash.com/photo-1560958089-b8a1929cea89?w=1200&q=80")
                .specChips(List.of("DUAL MOTOR AWD · 450 CV", "0-100 IN 3.1 SEC", "AUTOPILOT COCKPIT", "SUPERCHARGING"))
                .badgeText("ZERO EMISSIONS")
                .badgeColorValue(0xFF06B6D4L)
                .active(true)
                .build(),

            BannerItem.builder()
                .id("b_bmw")
                .tagline("THE ULTIMATE DRIVING MACHINE")
                .title("BMW 4 SERIES")
                .subtitle("TwinPower Turbo Performance • M Sport Aerodynamics")
                .vehicleId("v6")
                .priceText("$85 / DAY • AIRPORT PICKUP & INSURANCE")
                .imageUrl("https://images.unsplash.com/photo-1555215695-3004980ad54e?w=1200&q=80")
                .specChips(List.of("2.0L TWINPOWER · 258 CV", "0-100 IN 5.8 SEC · 250 KM/H", "M SPORT AERODYNAMICS", "HARMAN KARDON AUDIO"))
                .badgeText("M SPORT LUXURY")
                .badgeColorValue(0xFF2563EBL)
                .active(true)
                .build()
        ));
    }

    private void initCustomers() {
        customerRepository.saveAll(List.of(
            Customer.builder()
                .id("c1")
                .name("Sokha Seng")
                .phone("+855 12 345 678")
                .email("sokha.seng@gmail.com")
                .driverLicense("KH-9843210")
                .nationalId("010293847")
                .totalSpentCents(4500)
                .build(),
            Customer.builder()
                .id("c2")
                .name("Johnathan Miller")
                .phone("+1 415 555 2671")
                .email("j.miller@expats.com")
                .driverLicense("US-CA-B849201")
                .nationalId("P982019482")
                .totalSpentCents(12500)
                .build()
        ));

        rentalRepository.save(
            Rental.builder()
                .id("R-DEMO")
                .vehicleId("v1")
                .customerId("c1")
                .startDate(LocalDate.now())
                .endDate(LocalDate.now().plusDays(3))
                .dailyCents(6500)
                .paidCents(6500)
                .status("Active")
                .notes("VIP Concierge rental and airport handover.")
                .build()
        );
    }

    private void initAgency() {
        agencyConfigRepository.save(
            AgencyConfig.builder()
                .id("default")
                .companyName("DriveLine")
                .companySlogan("CAR RENTAL")
                .phone("+855 23 999 888")
                .email("booking@driveline-rental.com")
                .address("Phnom Penh & Siem Reap, Cambodia")
                .logoUrl(null)
                .build()
        );
    }
}

