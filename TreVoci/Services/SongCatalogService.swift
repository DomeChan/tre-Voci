import Foundation

@MainActor
final class SongCatalogService {
    let allSongs: [Song]

    init() {
        guard let url = Bundle.main.url(forResource: "SongCatalog", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let catalog = try? JSONDecoder().decode(SongCatalogData.self, from: data) else {
            assertionFailure("Failed to load SongCatalog.json from bundle")
            self.allSongs = []
            return
        }
        self.allSongs = catalog.songs

        #if DEBUG
        for song in catalog.songs {
            for (lang, path) in song.audioFiles {
                assert(
                    Self.audioURL(for: path) != nil,
                    "Missing audio file: \(path) for song \(song.id) language \(lang)"
                )
            }
        }
        #endif
    }

    var crossCulturalSongs: [Song] {
        allSongs.filter { $0.category == .crossCultural }
    }

    func songsByLanguage(_ language: Language) -> [Song] {
        switch language {
        case .it: return allSongs.filter { $0.category == .italian }
        case .zh: return allSongs.filter { $0.category == .chinese }
        case .en: return allSongs.filter { $0.category == .english }
        }
    }

    var italianSongs: [Song] { songsByLanguage(.it) }
    var chineseSongs: [Song] { songsByLanguage(.zh) }
    var englishSongs: [Song] { songsByLanguage(.en) }

    func song(byId id: String) -> Song? {
        allSongs.first { $0.id == id }
    }

    /// Resolves an audio file path (e.g. "cross-cultural/frere-jacques-it.m4a") to a bundle URL.
    /// Audio files live in the "Audio" folder reference in the bundle.
    static func audioURL(for path: String) -> URL? {
        let components = path.replacingOccurrences(of: ".m4a", with: "").split(separator: "/")
        if components.count == 2 {
            let subdirectory = "Audio/\(components[0])"
            let fileName = String(components[1])
            return Bundle.main.url(forResource: fileName, withExtension: "m4a", subdirectory: subdirectory)
        } else {
            return Bundle.main.url(forResource: path.replacingOccurrences(of: ".m4a", with: ""),
                                   withExtension: "m4a", subdirectory: "Audio")
        }
    }
}
