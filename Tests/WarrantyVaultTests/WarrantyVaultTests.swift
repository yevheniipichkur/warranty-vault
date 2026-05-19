import XCTest
import SwiftUI

final class WarrantyCalculatorTests: XCTestCase {
    func testTwelveMonthExpirationCalculation() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let purchaseDate = calendar.date(from: DateComponents(year: 2026, month: 1, day: 15))!

        let expiration = try XCTUnwrap(WarrantyCalculator.expirationDate(
            purchaseDate: purchaseDate,
            duration: .twelveMonths,
            calendar: calendar
        ))

        let components = calendar.dateComponents([.year, .month, .day], from: expiration)
        XCTAssertEqual(components.year, 2027)
        XCTAssertEqual(components.month, 1)
        XCTAssertEqual(components.day, 15)
    }

    func testNoWarrantyHasNoExpiration() {
        let expiration = WarrantyCalculator.expirationDate(purchaseDate: .now, duration: .noWarranty)
        XCTAssertNil(expiration)
    }
}

final class WarrantyStatusProviderTests: XCTestCase {
    func testExpiredWarranty() {
        let status = WarrantyStatusProvider.status(
            expirationDate: Date(timeIntervalSinceNow: -86_400),
            hasWarranty: true,
            today: .now
        )

        XCTAssertEqual(status, .expired)
    }

    func testExpiringSoonWarranty() {
        let status = WarrantyStatusProvider.status(
            expirationDate: Date(timeIntervalSinceNow: 10 * 86_400),
            hasWarranty: true,
            today: .now
        )

        XCTAssertEqual(status, .expiringSoon)
    }

    func testNoWarrantyStatus() {
        let status = WarrantyStatusProvider.status(
            expirationDate: nil,
            hasWarranty: false,
            today: .now
        )

        XCTAssertEqual(status, .noWarranty)
    }
}

final class ReturnWindowTests: XCTestCase {
    func testReturnDeadlineCalculation() throws {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let purchaseDate = calendar.date(from: DateComponents(year: 2026, month: 5, day: 1))!

        let deadline = try XCTUnwrap(ReturnWindowCalculator.deadlineDate(
            purchaseDate: purchaseDate,
            option: .thirtyDays,
            calendar: calendar
        ))

        let components = calendar.dateComponents([.year, .month, .day], from: deadline)
        XCTAssertEqual(components.year, 2026)
        XCTAssertEqual(components.month, 5)
        XCTAssertEqual(components.day, 31)
    }

    func testReturnWindowStatus() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let today = Date(timeIntervalSince1970: 0)
        let tomorrow = Date(timeIntervalSince1970: 86_400)

        XCTAssertEqual(ReturnWindowCalculator.status(deadlineDate: tomorrow, today: today, calendar: calendar), .available(daysLeft: 1))
        XCTAssertEqual(ReturnWindowCalculator.status(deadlineDate: nil, today: today, calendar: calendar), .none)
    }
}

final class RepairRecordTests: XCTestCase {
    func testWarrantyItemStoresRepairRecords() {
        let item = WarrantyItem(name: "Washer")
        let record = RepairRecord(serviceCenter: "Service", cost: 99, currency: "USD", notes: "Pump")

        item.addRepairRecord(record)

        XCTAssertEqual(item.repairRecords.count, 1)
        XCTAssertEqual(item.repairRecords.first?.serviceCenter, "Service")
    }
}

final class SubscriptionRulesTests: XCTestCase {
    func testFreeUserCanAddUpToTenItems() {
        XCTAssertTrue(SubscriptionRules.canAddItem(currentCount: 9, isPro: false))
        XCTAssertFalse(SubscriptionRules.canAddItem(currentCount: 10, isPro: false))
    }

    func testProUserCanAddBeyondFreeLimit() {
        XCTAssertTrue(SubscriptionRules.canAddItem(currentCount: 42, isPro: true))
    }

    func testSelectedAdvancedFeaturesRequirePro() {
        XCTAssertFalse(SubscriptionRules.isFeatureAvailable(.iCloudSync, isPro: false))
        XCTAssertFalse(SubscriptionRules.isFeatureAvailable(.barcodeScanner, isPro: false))
        XCTAssertFalse(SubscriptionRules.isFeatureAvailable(.calendarExport, isPro: false))
        XCTAssertFalse(SubscriptionRules.isFeatureAvailable(.repairHistory, isPro: false))
        XCTAssertTrue(SubscriptionRules.isFeatureAvailable(.iCloudSync, isPro: true))
        XCTAssertTrue(SubscriptionRules.isFeatureAvailable(.barcodeScanner, isPro: true))
        XCTAssertTrue(SubscriptionRules.isFeatureAvailable(.calendarExport, isPro: true))
        XCTAssertTrue(SubscriptionRules.isFeatureAvailable(.repairHistory, isPro: true))
    }
}

final class LanguageSelectionTests: XCTestCase {
    func testLanguageLocaleMapping() {
        XCTAssertEqual(AppLanguage.english.locale.identifier, "en")
        XCTAssertEqual(AppLanguage.polish.locale.identifier, "pl")
        XCTAssertEqual(AppLanguage.ukrainian.locale.identifier, "uk")
        XCTAssertEqual(AppLanguage.russian.locale.identifier, "ru")
    }

    func testLanguageStorageValues() {
        XCTAssertEqual(AppLanguage.system.rawValue, "system")
        XCTAssertEqual(AppLanguage.english.rawValue, "en")
    }
}

final class AppearanceSelectionTests: XCTestCase {
    func testAppearanceDefaultsAndSchemes() {
        XCTAssertNil(AppAppearance.system.colorScheme)
        XCTAssertEqual(AppAppearance.light.colorScheme, .light)
        XCTAssertEqual(AppAppearance.dark.colorScheme, .dark)
    }
}

final class ItemFilterSortTests: XCTestCase {
    func testSearchMatchesNameBrandStoreAndSerial() {
        let item = WarrantyItem(
            name: "Coffee machine",
            brand: "De'Longhi",
            serialNumber: "ABC123",
            store: "Kitchen Plus"
        )

        XCTAssertTrue(item.matchesSearch("coffee"))
        XCTAssertTrue(item.matchesSearch("longhi"))
        XCTAssertTrue(item.matchesSearch("abc"))
        XCTAssertTrue(item.matchesSearch("kitchen"))
    }

    func testFiltersIncludeExpectedStatuses() {
        let item = WarrantyItem(
            name: "AirPods",
            warrantyExpirationDate: Date(timeIntervalSinceNow: 7 * 86_400),
            hasWarranty: true
        )

        XCTAssertTrue(ItemFilter.expiringSoon.includes(item))
        XCTAssertFalse(ItemFilter.expired.includes(item))
    }

    func testNameSort() {
        let z = WarrantyItem(name: "Zebra")
        let a = WarrantyItem(name: "Alpha")

        let sorted = ItemSortOption.name.sort([z, a])

        XCTAssertEqual(sorted.map(\.name), ["Alpha", "Zebra"])
    }
}
