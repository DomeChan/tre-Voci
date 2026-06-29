import StoreKit
import SwiftUI

/// Optional, parent-gated "Support the Maker" tip jar. Reached only from inside
/// Parent Zone (behind the 3-second hold gate), so a toddler can never reach a
/// purchase. StoreKit consumables — unlocks nothing, every song stays free.
/// Honest offline state, no pressure, no nag, no celebration fireworks (calm).
struct DonationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var store = StoreService()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                header
                heroCard
                if store.didTip {
                    thankYouPanel
                } else {
                    tiersSection
                }
                footer
                Color.clear.frame(height: 24)
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .readableContentWidth(640)
        }
        .background(Color.cream)
        .task { await store.loadProducts() }
        .animation(reduceMotion ? nil : .spring(response: 0.4, dampingFraction: 0.8), value: store.didTip)
    }

    private var header: some View {
        HStack {
            Button("Done") { dismiss() }
                .font(.nunito(.semiBold, size: 15))
                .foregroundStyle(Color.coral)
            Spacer()
            Text("Support the Maker")
                .font(.nunito(.black, size: 17))
                .foregroundStyle(Color.bark)
            Spacer()
            Color.clear.frame(width: 50, height: 1)
        }
    }

    private var heroCard: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 36))
                .foregroundStyle(Color.coral)
            Text("A labor of love")
                .font(.nunito(.black, size: 20))
                .foregroundStyle(Color.bark)
            Text("Tre Voci is built by one dad for his trilingual toddler \u{2014} no ads, no tracking, no subscriptions. Every song stays free, forever. If it's brought some calm to your home, a tip helps cover the Apple Developer fee and re-mastering the audio. Completely optional \u{2014} ignore this and you lose nothing.")
                .font(.nunito(.medium, size: 14))
                .foregroundStyle(Color.stone)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.05), radius: 10, y: 3)
    }

    @ViewBuilder
    private var tiersSection: some View {
        switch store.state {
        case .loading:
            VStack(spacing: 10) {
                ProgressView()
                Text("Loading\u{2026}")
                    .font(.nunito(.medium, size: 13))
                    .foregroundStyle(Color.stone)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
        case .loaded(let products):
            VStack(spacing: 12) {
                ForEach(products, id: \.id) { product in
                    TipTierCard(
                        product: product,
                        emoji: store.emoji(for: product),
                        blurb: store.blurb(for: product),
                        inFlight: store.purchaseInFlight == product.id,
                        disabled: store.purchaseInFlight != nil,
                        action: { Task { await store.purchase(product) } }
                    )
                }
                if let err = store.purchaseError {
                    Text(err)
                        .font(.nunito(.medium, size: 12))
                        .foregroundStyle(Color.stone)
                }
            }
        case .unavailable:
            unavailablePanel
        }
    }

    private var unavailablePanel: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 32))
                .foregroundStyle(Color.mist)
            Text("Tips need a connection")
                .font(.nunito(.black, size: 16))
                .foregroundStyle(Color.bark)
            Text("The App Store isn't reachable right now, so tips are paused. Nothing's wrong \u{2014} the app works fully offline, and your support can wait. Try again anytime.")
                .font(.nunito(.medium, size: 13))
                .foregroundStyle(Color.stone)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button("Try again") { Task { await store.loadProducts() } }
                .font(.nunito(.bold, size: 14))
                .foregroundStyle(Color.coral)
                .frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var thankYouPanel: some View {
        VStack(spacing: 12) {
            Image(systemName: "heart.fill")
                .font(.system(size: 40))
                .foregroundStyle(Color.coral)
            Text("Grazie \u{00B7} \u{8C22}\u{8C22} \u{00B7} Thank you")
                .font(.nunito(.black, size: 22))
                .foregroundStyle(Color.bark)
                .multilineTextAlignment(.center)
            Text("Truly \u{2014} this keeps the lights on. Now go sing something.")
                .font(.nunito(.medium, size: 14))
                .foregroundStyle(Color.stone)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Button("Close") { dismiss() }
                .font(.nunito(.bold, size: 15))
                .foregroundStyle(Color.coral)
                .frame(minHeight: 44)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    private var footer: some View {
        Text("Payments are handled by Apple. Tre Voci never sees your card, and collects nothing about you.")
            .font(.nunito(.semiBold, size: 11))
            .foregroundStyle(Color.stone)
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
    }
}

/// One tip tier row. ≥56pt tall, price pill ≥44pt — comfortably toddler-proof
/// sizing for the parent's one-handed tap.
private struct TipTierCard: View {
    let product: Product
    let emoji: String
    let blurb: String
    let inFlight: Bool
    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                Text(emoji)
                    .font(.system(size: 28))
                VStack(alignment: .leading, spacing: 2) {
                    Text(product.displayName)
                        .font(.nunito(.bold, size: 15))
                        .foregroundStyle(Color.bark)
                    Text(blurb)
                        .font(.nunito(.medium, size: 12))
                        .foregroundStyle(Color.stone)
                }
                Spacer()
                Group {
                    if inFlight {
                        ProgressView()
                    } else {
                        Text(product.displayPrice)
                            .font(.nunito(.black, size: 15))
                            .foregroundStyle(Color.bark)
                    }
                }
                .frame(minWidth: 64, minHeight: 44)
                .padding(.horizontal, 12)
                .background(Color.coral)
                .clipShape(Capsule())
            }
            .padding(14)
            .frame(maxWidth: .infinity, minHeight: 56)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.04), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
        .accessibilityLabel("Tip \(product.displayName), \(product.displayPrice)")
    }
}

#if DEBUG
#Preview {
    DonationView()
}
#endif
