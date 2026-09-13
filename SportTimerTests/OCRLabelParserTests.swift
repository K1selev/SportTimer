import XCTest
@testable import SportTimer

final class OCRLabelParserTests: XCTestCase {
    func testParsesCaloriesAndMacrosFromRussianLabel() {
        let result = OCRLabelParser.parse(lines: [
            "Творог",
            "на 100 г",
            "ккал 121",
            "белки 16.0",
            "жиры 5.0",
            "углеводы 3.0"
        ])

        XCTAssertEqual(result.name, "Творог")
        XCTAssertEqual(result.facts?.calories, 121)
        XCTAssertEqual(result.facts?.protein, 16)
        XCTAssertEqual(result.facts?.fat, 5)
        XCTAssertEqual(result.facts?.carbs, 3)
        XCTAssertEqual(result.facts?.servingSize, 100)
        XCTAssertEqual(result.facts?.servingUnit, "г")
    }

    func testCalculatesCaloriesFromMacrosWhenCaloriesMissing() {
        let result = OCRLabelParser.parse(lines: [
            "Protein bar",
            "protein 10",
            "fat 5",
            "carb 20"
        ])

        XCTAssertEqual(result.name, "Protein bar")
        XCTAssertEqual(result.facts?.calories, 165)
    }

    func testReturnsNilFactsWhenNutritionDataIsMissing() {
        let result = OCRLabelParser.parse(lines: ["Just a random package label"])

        XCTAssertNil(result.facts)
    }
}
