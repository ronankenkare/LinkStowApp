import Foundation
import LinkPresentation
import SwiftSoup

final class LinkMetadataService {

    private let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()

    // VERIFY LINK
    // Description: Verify that the link is real and accessible.
    // Input:       URL string
    // Output:      Verified URL string (with https:// or http:// added if needed).
    //              Nil - Link is not real or accessible.
    func verifyLink(from urlString: String) async throws -> String? {
        // Helper function to verify a URL string
        func verifyURL(_ urlStr: String) async throws -> Bool {
            guard let url = URL(string: urlStr),
                url.scheme?.hasPrefix("http") == true else {
                return false
            }

            do {
                let (data, response) = try await session.data(from: url)
                if let http = response as? HTTPURLResponse, !(200...399).contains(http.statusCode) {
                    return false
                }
                let html = String(decoding: data, as: UTF8.self)
                _ = try SwiftSoup.parse(html)
                return true
            } catch {
                // Network errors or parsing errors -> not verified
                return false
            }
        }
        
        // Try the original URL first
        if try await verifyURL(urlString) {
            return urlString
        }
        
        // If it failed and doesn't start with http:// or https://, try adding https://
        let lowercased = urlString.lowercased()
        if !lowercased.hasPrefix("http://") && !lowercased.hasPrefix("https://") {
            let httpsURL = "https://" + urlString
            if try await verifyURL(httpsURL) {
                return httpsURL
            }
            
            // If https:// failed, try http://
            let httpURL = "http://" + urlString
            if try await verifyURL(httpURL) {
                return httpURL
            }
        }
        
        return nil
    }

    // FETCH WEBSITE TITLE
    // Description: Fetch the title of the website.
    // Input:       URL string
    // Output:      Title of the website.
    //              Nil - Failed to fetch title.
    func fetchWebsiteTitle(from urlString: String) async throws -> String? {
        guard let url = URL(string: urlString),
            url.scheme?.hasPrefix("http") == true else {
            return nil
        }

        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...399).contains(http.statusCode) {
                return nil
            }
            let html = String(decoding: data, as: UTF8.self)
            let document = try SwiftSoup.parse(html)
            let title = try document.title()
            return title.isEmpty ? nil : title
        } catch {
            return nil
        }
    }

    // FETCH WEBSITE DESCRIPTION
    // Description: Fetch the description of the website.
    // Input:       URL string
    // Output:      Description of the website.
    //              Nil - Failed to fetch description.
    func fetchWebsiteDescription(from urlString: String) async throws -> String? {
        guard let url = URL(string: urlString),
            url.scheme?.hasPrefix("http") == true else {
            return nil
        }

        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...399).contains(http.statusCode) {
                return nil
            }
            let html = String(decoding: data, as: UTF8.self)
            let document = try SwiftSoup.parse(html)
            if let meta: Element = try document.select("meta[name='description'], meta[name='Description']").first() {
                let content = try meta.attr("content")
                return content.isEmpty ? nil : content
            }
            return nil
        } catch {
            return nil
        }
    }

    // FETCH WEBSITE ICON
    // Description: Fetch the icon image bytes of the website (favicon or touch icon).
    // Input:       URL string
    // Output:      Image data for the icon.
    //              Nil - Failed to fetch icon or not an image.
    func fetchWebsiteIcon(from urlString: String) async throws -> Data? {
        guard let url = URL(string: urlString),
            url.scheme?.hasPrefix("http") == true else {
            return nil
        }

        // Attempt to fetch HTML and locate a favicon-like link. If parsing finds none,
        // we will fall back to the conventional /favicon.ico path at the site root.
        // If the network request itself fails, return nil (do not attempt fallback).
        do {
            let (data, response) = try await session.data(from: url)
            if let http = response as? HTTPURLResponse, !(200...399).contains(http.statusCode) {
                return nil
            }
            let html = String(decoding: data, as: UTF8.self)
            let document = try SwiftSoup.parse(html)

            // Common favicon selectors ordered by typical preference
            let selectors = [
                "link[rel~=icon]",                                    // rel contains 'icon'
                "link[rel~=shortcut][rel~=icon]",                      // 'shortcut icon'
                "link[rel~=apple-touch-icon-precomposed]",
                "link[rel~=apple-touch-icon]",
                "link[rel~=mask-icon]"
            ]

            // Helper to download and validate image content
            func downloadImageData(from candidate: URL) async -> Data? {
                do {
                    let (imgData, imgResponse) = try await session.data(from: candidate)
                    if let http = imgResponse as? HTTPURLResponse, !(200...399).contains(http.statusCode) {
                        return nil
                    }
                    if let mime = (imgResponse as? HTTPURLResponse)?.value(forHTTPHeaderField: "Content-Type")?.lowercased(),
                       mime.hasPrefix("image/") {
                        return imgData
                    }
                    // Some servers omit Content-Type or send octet-stream; accept small-ish blobs as icons
                    // if size is within a reasonable icon range (>0 and < 1MB)
                    if imgData.count > 0 && imgData.count < 1_000_000 {
                        return imgData
                    }
                    return nil
                } catch {
                    return nil
                }
            }

            for selector in selectors {
                if let element = try document.select(selector).first() {
                    let href = try element.attr("href")
                    if !href.isEmpty, let resolved = URL(string: href, relativeTo: url)?.absoluteURL {
                        if let imageData = await downloadImageData(from: resolved) {
                            return imageData
                        }
                    }
                }
            }

            // Fallback: Some sites expose icons via Open Graph image (not strictly a favicon but useful)
            if let ogImage = try document.select("meta[property=og:image]").first() {
                let content = try ogImage.attr("content")
                if !content.isEmpty, let resolved = URL(string: content, relativeTo: url)?.absoluteURL {
                    if let imageData = await downloadImageData(from: resolved) {
                        return imageData
                    }
                }
            }
            
            // Final fallback: try standard /favicon.ico at the site root (only if fetch succeeded)
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
            components?.path = "/favicon.ico"
            components?.query = nil
            if let fallbackUrl = components?.url, let imageData = await downloadImageData(from: fallbackUrl) {
                return imageData
            }
            return nil
        } catch {
            // Network error (e.g., unreachable host) -> no icon
            return nil
        }
    }

    
    
}


