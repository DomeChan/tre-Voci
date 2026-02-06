import Foundation

@Observable
@MainActor
final class PersistenceService {
    private static let appStateKey = "tre_voci_app_state"
    private static let onboardingKey = "tre_voci_onboarding_complete"

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private(set) var state: AppState

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.appStateKey),
           let decoded = try? JSONDecoder().decode(AppState.self, from: data) {
            self.state = decoded
        } else {
            self.state = AppState()
        }
        checkWeekRollover()
    }

    func save() {
        guard let data = try? encoder.encode(state) else { return }
        defaults.set(data, forKey: Self.appStateKey)
        defaults.set(state.hasCompletedOnboarding, forKey: Self.onboardingKey)
    }

    func update(_ transform: (inout AppState) -> Void) {
        transform(&state)
        save()
    }

    func resetAll() {
        defaults.removeObject(forKey: Self.appStateKey)
        defaults.removeObject(forKey: Self.onboardingKey)
        state = AppState()
    }

    private func checkWeekRollover() {
        let calendar = Calendar.current
        let now = Date()
        if let weekStart = state.weekStartDate,
           !calendar.isDate(weekStart, equalTo: now, toGranularity: .weekOfYear) {
            state.weeklyListeningSeconds = ["it": 0, "zh": 0, "en": 0]
            state.weekStartDate = calendar.startOfDay(for: now)
            save()
        }
        if state.weekStartDate == nil {
            state.weekStartDate = calendar.startOfDay(for: now)
            save()
        }
    }
}
