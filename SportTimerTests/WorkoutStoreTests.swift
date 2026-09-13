import CoreData
import XCTest
@testable import SportTimer

@MainActor
final class WorkoutStoreTests: XCTestCase {
    func testAddWorkoutPersistsAndSortsNewestFirst() async throws {
        let store = try await makeStore()
        let older = try XCTUnwrap(Calendar.current.date(byAdding: .day, value: -1, to: Date()))
        let newer = Date()

        await store.addWorkout(type: WorkoutType.cardio.rawValue, duration: 1_800, date: older, notes: "Easy")
        await store.addWorkout(type: WorkoutType.strength.rawValue, duration: 2_400, date: newer, notes: "Heavy")

        XCTAssertEqual(store.workouts.count, 2)
        XCTAssertEqual(store.workouts.first?.type, WorkoutType.strength.rawValue)
        XCTAssertEqual(store.workouts.first?.duration, 2_400)
        XCTAssertEqual(store.workouts.last?.notes, "Easy")
    }

    func testDeleteWorkoutRemovesItemFromStore() async throws {
        let store = try await makeStore()
        await store.addWorkout(type: WorkoutType.yoga.rawValue, duration: 900, date: Date(), notes: nil)

        let workout = try XCTUnwrap(store.workouts.first)
        store.deleteWorkout(workout)

        XCTAssertTrue(store.workouts.isEmpty)
    }

    func testDeleteAllWorkoutsClearsStore() async throws {
        let store = try await makeStore()
        await store.addWorkout(type: WorkoutType.cardio.rawValue, duration: 1_200, date: Date(), notes: nil)
        await store.addWorkout(type: WorkoutType.swimming.rawValue, duration: 1_500, date: Date(), notes: nil)

        store.deleteAllWorkouts()

        XCTAssertTrue(store.workouts.isEmpty)
    }

    private func makeStore() async throws -> WorkoutStore {
        let model = try XCTUnwrap(NSManagedObjectModel.mergedModel(from: Bundle.allBundles))
        let container = NSPersistentContainer(name: "WorkoutModel", managedObjectModel: model)
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            container.loadPersistentStores { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }

        return WorkoutStore(context: container.viewContext)
    }
}
