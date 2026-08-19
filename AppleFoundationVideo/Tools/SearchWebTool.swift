import Foundation
import FoundationModels

struct SearchWebTool: Tool {
    let name = "searchWeb"
    let description = "Searches the live web and Wikipedia for current information, facts, video games, movies, definitions, biographies, and real-time topics. Use this tool when the user asks for real-time information or specific web knowledge."
    
    @Generable
    struct Arguments {
        @Guide(description: "The search query keywords (e.g. 'Wolverine game', 'Apple Vision Pro', 'Swift 6', 'Latest Mars rover news')")
        var query: String
    }
    
    let onSearchStateChange: (@MainActor (Bool) -> Void)?
    
    init(onSearchStateChange: (@MainActor (Bool) -> Void)? = nil) {
        self.onSearchStateChange = onSearchStateChange
    }
    
    func call(arguments: Arguments) async throws -> some PromptRepresentable {
        await onSearchStateChange?(true)
        defer {
            Task { @MainActor in
                onSearchStateChange?(false)
            }
        }
        
        let cleanQuery = arguments.query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let encoded = cleanQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            return "Could not search the web for '\(cleanQuery)'."
        }
        
        // 1. Wikipedia Full-Text Search + Page Summary
        if let wikiResult = await searchWikipedia(query: cleanQuery, encoded: encoded) {
            return "Web & Wikipedia results for '\(cleanQuery)':\n\(wikiResult)"
        }
        
        // 2. DuckDuckGo Instant Answer Fallback
        if let ddgResult = await fetchDuckDuckGo(encoded: encoded) {
            return "Web search results for '\(cleanQuery)':\n\(ddgResult)"
        }
        
        return "No direct web search results found for '\(cleanQuery)'."
    }
    
    // MARK: - Intelligent Full-Text Wikipedia Search
    private func searchWikipedia(query: String, encoded: String) async -> String? {
        // Step A: Search for matching articles
        guard let searchUrl = URL(string: "https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=\(encoded)&format=json&utf8=1") else { return nil }
        
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
            
            // Collect snippets from top results
            var textSnippets: [String] = []
            let topTitle = searchResults[0]["title"] as? String ?? query
            
            // Step B: Fetch full introductory summary for the top article
            if let summary = await fetchArticleSummary(title: topTitle) {
                textSnippets.append(summary)
            }
            
            // Add related snippets from search results
            for result in searchResults.prefix(3) {
                if let title = result["title"] as? String,
                   let rawSnippet = result["snippet"] as? String {
                    let cleanSnippet = rawSnippet
                        .replacingOccurrences(of: "<span class=\"searchmatch\">", with: "")
                        .replacingOccurrences(of: "</span>", with: "")
                        .replacingOccurrences(of: "&quot;", with: "\"")
                        .replacingOccurrences(of: "&#039;", with: "'")
                    
                    if title != topTitle {
                        textSnippets.append("• \(title): \(cleanSnippet)")
                    }
                }
            }
            
            return textSnippets.isEmpty ? nil : textSnippets.joined(separator: "\n\n")
        } catch {
            return nil
        }
    }
    
    private func fetchArticleSummary(title: String) async -> String? {
        guard let encodedTitle = title.replacingOccurrences(of: " ", with: "_").addingPercentEncoding(withAllowedCharacters: .urlPathAllowed),
              let url = URL(string: "https://en.wikipedia.org/api/rest_v1/page/summary/\(encodedTitle)") else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("AppleFoundationAssistant/1.0", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let extract = json["extract"] as? String, !extract.isEmpty {
                return "\(title):\n\(extract)"
            }
        } catch {
            return nil
        }
        return nil
    }
    
    // MARK: - DuckDuckGo Instant Answer
    private func fetchDuckDuckGo(encoded: String) async -> String? {
        guard let url = URL(string: "https://api.duckduckgo.com/?q=\(encoded)&format=json&no_html=1&no_redirect=1") else { return nil }
        
        var request = URLRequest(url: url)
        request.setValue("Mozilla/5.0 (iPhone; CPU iPhone OS 18_0 like Mac OS X)", forHTTPHeaderField: "User-Agent")
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard (response as? HTTPURLResponse)?.statusCode == 200 else { return nil }
            
            if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                var results: [String] = []
                
                if let abstract = json["AbstractText"] as? String, !abstract.isEmpty {
                    results.append(abstract)
                }
                
                if let answer = json["Answer"] as? String, !answer.isEmpty {
                    results.append(answer)
                }
                
                if let definition = json["Definition"] as? String, !definition.isEmpty {
                    results.append(definition)
                }
                
                if let related = json["RelatedTopics"] as? [[String: Any]] {
                    for topic in related.prefix(3) {
                        if let text = topic["Text"] as? String, !text.isEmpty {
                            results.append(text)
                        }
                    }
                }
                
                if !results.isEmpty {
                    return results.joined(separator: "\n\n")
                }
            }
        } catch {
            return nil
        }
        return nil
    }
}
