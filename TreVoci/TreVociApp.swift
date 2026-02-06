import SwiftUI

@main
struct TreVociApp: App {
    @State private var persistence = PersistenceService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(persistence)
        }
    }
}

struct ContentView: View {
    @Environment(PersistenceService.self) private var persistence
    @State private var flowState: FlowState = .splash

    enum FlowState {
        case splash
        case onboarding
        case home
    }

    var body: some View {
        ZStack {
            switch flowState {
            case .splash:
                SplashView {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        flowState = .onboarding
                    }
                }
                .transition(.opacity)

            case .onboarding:
                OnboardingContainer {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        flowState = .home
                    }
                }
                .transition(.move(edge: .trailing).combined(with: .opacity))

            case .home:
                HomeView()
                    .transition(.opacity)
            }
        }
        .onAppear {
            if persistence.state.hasCompletedOnboarding {
                flowState = .home
            }
        }
    }
}
