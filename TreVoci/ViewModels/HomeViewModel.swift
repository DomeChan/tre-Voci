import Foundation

@Observable
@MainActor
final class HomeViewModel {
    private let catalog: SongCatalogService
    private let persistence: PersistenceService

    var crossCulturalSongs: [Song] { catalog.crossCulturalSongs }
    var italianSongs: [Song] { catalog.italianSongs }
    var chineseSongs: [Song] { catalog.chineseSongs }
    var englishSongs: [Song] { catalog.englishSongs }

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
        let seed = Calendar.current.startOfDay(for: date).hashValue
        var rng = SeededRandomNumberGenerator(seed: UInt64(bitPattern: Int64(seed)))
        let songs = crossCulturalSongs.shuffled(using: &rng)
        return Array(songs.prefix(sessionLength))
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
