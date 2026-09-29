#if !NO_HEALTHKIT
import Foundation
import HealthKit
import Observation

/// Runs the HealthKit spike: authorization, then a short `.tennis` workout session.
/// Every step reports success or the exact error, so the result can be read off the watch.
@MainActor
@Observable
final class HealthCheckModel: NSObject, HKWorkoutSessionDelegate {
    enum Status {
        case pending
        case running
        case ok(String)
        case failed(String)

        var symbol: String {
            switch self {
            case .pending: "·"
            case .running: "..."
            case .ok: "OK"
            case .failed: "FAIL"
            }
        }

        var detail: String? {
            switch self {
            case .ok(let text), .failed(let text): text
            default: nil
            }
        }

        var isFailure: Bool {
            if case .failed = self { return true }
            return false
        }

        var isOK: Bool {
            if case .ok = self { return true }
            return false
        }
    }

    struct Step: Identifiable {
        let id: Int
        let title: String
        var status: Status = .pending
    }

    private(set) var steps: [Step] = HealthCheckModel.freshSteps()
    private(set) var isRunning = false
    private(set) var verdict: String?

    var allPassed: Bool {
        steps.allSatisfy { $0.status.isOK }
    }

    private let store = HKHealthStore()
    private var session: HKWorkoutSession?
    private var builder: HKLiveWorkoutBuilder?
    private var sessionState: HKWorkoutSessionState = .notStarted
    private var sessionError: String?

    private static func freshSteps() -> [Step] {
        [
            "HealthKit available",
            "Authorization",
            "Workout session",
            "Session running",
            "Session ended",
        ].enumerated().map { Step(id: $0.offset, title: $0.element) }
    }

    func run() {
        guard !isRunning else { return }
        isRunning = true
        verdict = nil
        steps = Self.freshSteps()
        sessionState = .notStarted
        sessionError = nil
        Task {
            await execute()
            verdict = allPassed
                ? "HealthKit works with this signature."
                : "HealthKit failed. Send the red text above."
            isRunning = false
        }
    }

    private func set(_ index: Int, _ status: Status) {
        steps[index].status = status
    }

    private static func describe(_ error: Error) -> String {
        let ns = error as NSError
        return "\(ns.domain) \(ns.code): \(ns.localizedDescription)"
    }

    private func execute() async {
        // 0. availability
        set(0, .running)
        guard HKHealthStore.isHealthDataAvailable() else {
            set(0, .failed("isHealthDataAvailable() is false"))
            return
        }
        set(0, .ok("yes"))

        // 1. authorization
        set(1, .running)
        let workoutType = HKObjectType.workoutType()
        let readTypes: Set<HKObjectType> = [
            HKQuantityType(.heartRate),
            HKQuantityType(.activeEnergyBurned),
        ]
        let shareTypes: Set<HKSampleType> = [workoutType]
        do {
            try await store.requestAuthorization(toShare: shareTypes, read: readTypes)
            let share = store.authorizationStatus(for: workoutType)
            switch share {
            case .sharingAuthorized:
                set(1, .ok("workouts: allowed"))
            case .sharingDenied:
                set(1, .failed("workouts: denied by user"))
                return
            case .notDetermined:
                set(1, .failed("workouts: not determined"))
                return
            @unknown default:
                set(1, .failed("workouts: unknown status \(share.rawValue)"))
                return
            }
        } catch {
            set(1, .failed(Self.describe(error)))
            return
        }

        // 2. create and start a tennis workout session
        set(2, .running)
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .tennis
        configuration.locationType = .outdoor
        let newSession: HKWorkoutSession
        do {
            newSession = try HKWorkoutSession(healthStore: store, configuration: configuration)
        } catch {
            set(2, .failed(Self.describe(error)))
            return
        }
        let newBuilder = newSession.associatedWorkoutBuilder()
        newBuilder.dataSource = HKLiveWorkoutDataSource(
            healthStore: store, workoutConfiguration: configuration)
        newSession.delegate = self
        session = newSession
        builder = newBuilder
        let start = Date()
        newSession.startActivity(with: start)
        do {
            try await newBuilder.beginCollection(at: start)
        } catch {
            set(2, .failed("beginCollection: \(Self.describe(error))"))
            newSession.end()
            return
        }
        set(2, .ok("created as .tennis"))

        // 3. wait for the running state
        set(3, .running)
        if await waitFor({ $0 == .running }, seconds: 5) {
            set(3, .ok("state running"))
        } else {
            set(3, .failed(sessionError ?? "not running after 5 s (state \(sessionState.rawValue))"))
            newSession.end()
            return
        }

        // let it run for a few seconds
        try? await Task.sleep(for: .seconds(4))

        // 4. end it and throw the data away
        set(4, .running)
        newSession.end()
        let ended = await waitFor({ $0 == .ended }, seconds: 5)
        do {
            try await newBuilder.endCollection(at: Date())
            newBuilder.discardWorkout()
        } catch {
            set(4, .failed("endCollection: \(Self.describe(error))"))
            return
        }
        if ended {
            set(4, .ok("state ended, workout discarded"))
        } else {
            set(4, .failed(sessionError ?? "not ended after 5 s (state \(sessionState.rawValue))"))
        }
        session = nil
        builder = nil
    }

    private func waitFor(_ predicate: (HKWorkoutSessionState) -> Bool, seconds: Int) async -> Bool {
        for _ in 0..<(seconds * 10) {
            if predicate(sessionState) { return true }
            if sessionError != nil { return false }
            try? await Task.sleep(for: .milliseconds(100))
        }
        return predicate(sessionState)
    }

    // MARK: HKWorkoutSessionDelegate

    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didChangeTo toState: HKWorkoutSessionState,
        from fromState: HKWorkoutSessionState,
        date: Date
    ) {
        Task { @MainActor in self.sessionState = toState }
    }

    nonisolated func workoutSession(
        _ workoutSession: HKWorkoutSession,
        didFailWithError error: Error
    ) {
        let text = Self.describe(error)
        Task { @MainActor in self.sessionError = text }
    }
}
#endif
