import Foundation

@Observable
@MainActor
final class HomeViewModel {
    private let catalog: SongCatalogService
    private let persistence: PersistenceService

    var crossCulturalSongs: [Song] { catalog.crossCulturalSongs }

    /// Culture-specific songs for any language — replaces the old per-language
    /// accessors so Home can iterate `Language.all` instead of hardcoding three.
    func songs(for language: Language) -> [Song] { catalog.songsByLanguage(language) }

    var childName: String { persistence.state.displayName }
    var sessionLength: Int { persistence.state.sessionLength }

    init(catalog: SongCatalogService, persistence: PersistenceService) {
        self.catalog = catalog
        self.persistence = persistence
    }

    var dailyMix: [Song] {
        dailyMix(for: Date())
    }

    var dailyMixDuration: Int {
        dailyMix.reduce(0) { $0 + $1.duration }
    }

    func dailyMix(for date: Date) -> [Song] {
        // Bedtime Mode narrows the pool to calm songs (and plays fewer).
        var pool = crossCulturalSongs
        if persistence.state.bedtimeMode {
            let calm = pool.filter { $0.isCalm }
            if !calm.isEmpty { pool = calm }
        }

        // Least-heard-first: songs the child has heard least surface first, so
        // exposure stays balanced instead of replaying the same favourites. The
        // daily seed only breaks ties, so the order still rotates day to day.
        let counts = playCounts()
        let seed = Calendar.current.startOfDay(for: date).hashValue
        var rng = SeededRandomNumberGenerator(seed: UInt64(bitPattern: Int64(seed)))
        let ranked = pool
            .map { (song: $0, tieBreak: rng.next()) }
            .sorted { lhs, rhs in
                let lc = counts[lhs.song.id, default: 0]
                let rc = counts[rhs.song.id, default: 0]
                if lc != rc { return lc < rc }
                return lhs.tieBreak < rhs.tieBreak
            }
            .map(\.song)

        return Array(ranked.prefix(sessionLength))
    }

    /// How many times each song has been played, from listening history.
    private func playCounts() -> [String: Int] {
        var counts: [String: Int] = [:]
        for session in persistence.state.sessions {
            counts[session.songId, default: 0] += 1
        }
        return counts
    }

    func song(byId id: String) -> Song? {
        catalog.song(byId: id)
    }
}

// MARK: - Seeded RNG for deterministic daily shuffle

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        // xorshift64
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}
