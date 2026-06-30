import Foundation
import StoreKit

/// Wraps StoreKit 2 for the optional, parent-gated "Support the Maker" tip jar.
///
/// Consumable tips only — nothing is unlocked, every song stays free, and we
/// write no network calls and collect nothing about the user (Apple handles the
/// payment). If the App Store is unreachable the service reports `.unavailable`
/// and the UI shows an honest paused state rather than a fake price or a crash.
@MainActor
@Observable
final class StoreService {

    /// The three tip tiers. Product IDs share the bundle prefix so they're
    /// obvious in App Store Connect later. Order is small → medium → large.
    enum Tip: String, CaseIterable {
        case small = "com.trevoci.tip.small"
        case medium = "com.trevoci.tip.medium"
        case large = "com.trevoci.tip.large"

        var order: Int { Self.allCases.firstIndex(of: self) ?? 0 }

        var emoji: String {
            switch self {
            case .small: return "\u{2615}\u{FE0F}"   // ☕️
            case .medium: return "\u{1F35D}"          // 🍝
            case .large: return "\u{1F381}"           // 🎁
            }
        }

        var blurb: String {
            switch self {
            case .small: return "buys a coffee"
            case .medium: return "a plate of pasta"
            case .large: return "a month of hosting"
            }
        }
    }

    enum LoadState {
        case loading
        case loaded([Product])
        case unavailable
    }

    var state: LoadState = .loading
    var purchaseInFlight: Product.ID?
    var didTip = false
    var purchaseError: String?

    /// Load the tip products. Any failure (offline, StoreKit down) resolves to
    /// `.unavailable` — never a thrown error reaching the UI, never a fake price.
    func loadProducts() async {
        state = .loading
        purchaseError = nil
        do {
            let products = try await Product.products(for: Tip.allCases.map(\.rawValue))
            let sorted = products.sorted {
                (Tip(rawValue: $0.id)?.order ?? 0) < (Tip(rawValue: $1.id)?.order ?? 0)
            }
            state = sorted.isEmpty ? .unavailable : .loaded(sorted)
        } catch {
            state = .unavailable
        }
    }

    /// Purchase a tip. Consumables finish immediately and store nothing; cancel
    /// and pending are silent no-ops (no guilt, no nag). Verification failures
    /// are ignored. Errors surface as a quiet inline line, never a modal storm.
    func purchase(_ product: Product) async {
        guard purchaseInFlight == nil else { return }
        purchaseInFlight = product.id
        purchaseError = nil
        defer { purchaseInFlight = nil }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else { return }
                await transaction.finish()
                didTip = true
            case .userCancelled, .pending:
                break
            @unknown default:
                break
            }
        } catch {
            purchaseError = "Couldn't complete \u{2014} you weren't charged."
        }
    }

    func emoji(for product: Product) -> String { Tip(rawValue: product.id)?.emoji ?? "\u{1F49B}" }
    func blurb(for product: Product) -> String { Tip(rawValue: product.id)?.blurb ?? "" }
}
