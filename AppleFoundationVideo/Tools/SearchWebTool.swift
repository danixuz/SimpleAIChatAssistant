import Foundation
import FoundationModels

struct SearchWebTool: Tool {
    let name = "searchWeb"
    let description = "Searches Wikipedia and the web for up-to-date facts, video games, movies, technology, release dates, and news. Pay close attention to the medium requested (e.g. video game vs movie vs book)."
    
    @Generable
    struct Arguments {
        @Guide(description: "The specific search query keywords (e.g. 'Marvel's Wolverine video game release date', 'Marvel's Spider-Man 2 release date')")
        var query: String
    }
    
    let onSearchStateChange: (@MainActor (Bool) -> Void)?
    
    init(onSearchStateChange: (@MainActor (Bool) -> Void)? = nil) {
        self.onSearchStateChange = onSearchStateChange
    }
    
    func call(arguments: Arguments) async throws -> some PromptRepresentable {
        await onSearchStateChange?(true)
        
        let startTime = Date()
        defer {
            Task { @MainActor in
                let elapsed = Date().timeIntervalSince(startTime)
                if elapsed < 0.7 {
                    try? await Task.sleep(nanoseconds: UInt64((0.7 - elapsed) * 1_000_000_000))
                }
                onSearchStateChange?(false)
            }
        }
        
        let cleanQuery = arguments.query.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let wikiResults = await searchWikipedia(query: cleanQuery) {
            return "Search Results for '\(cleanQuery)':\n\n\(wikiResults)"
        }
        
        return "No direct search results found for '\(cleanQuery)'."
    }
    
    // MARK: - Focused Multi-Result Search
    private func searchWikipedia(query: String) async -> String? {
        guard let encoded = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let searchUrl = URL(string: "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=\(encoded)&srlimit=5&format=json&utf8=1") else { return nil }
        
        var request = URLRequest(url: searchUrl)
        request.setValue("AppleFoundationAssistant/1.0 (contact: info@example.com)", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let queryObj = json["query"] as? [String: Any],
                  let searchResults = queryObj["search"] as? [[String: Any]],
                  !searchResults.isEmpty else {
                return nil
            }
            
            var formattedResults: [String] = []
            
            for result in searchResults.prefix(4) {
                if let title = result["title"] as? String,
                   let rawSnippet = result["snippet"] as? String {
                    let cleanSnippet = cleanHTML(rawSnippet)
                    if !cleanSnippet.isEmpty {
                        let truncated = cleanSnippet.count > 160 ? String(cleanSnippet.prefix(160)) + "..." : cleanSnippet
                        formattedResults.append("• [\(title)]: \(truncated)")
                    }
                }
            }
            
            guard !formattedResults.isEmpty else { return nil }
            
            let combined = formattedResults.joined(separator: "\n\n")
            return String(combined.prefix(900))
        } catch {
            return nil
        }
    }
    
    // MARK: - HTML Entity Cleaner Helper
    private func cleanHTML(_ string: String) -> String {
        var clean = string
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "<b>", with: "")
            .replacingOccurrences(of: "</b>", with: "")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .replacingOccurrences(of: "&#x27;", with: "'")
            .replacingOccurrences(of: "&#39;", with: "'")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "\n", with: " ")
        
        while clean.contains("  ") {
            clean = clean.replacingOccurrences(of: "  ", with: " ")
        }
        
        return clean.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
