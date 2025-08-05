//
//  GeminiService.swift
//  FresherAPP
//
//  Created by D K on 04.08.2025.
//

import Foundation
import UIKit

struct ProductInfo {
    let name: String
    let expirationDate: Date?
    let notes: String?
}

final class GeminiService {
    
    private let apiKey = "AIzaSyDeKZRT21892LO6NjoSWdWgq3OfXeiOG1c"
    private let modelName = "gemini-1.5-flash"
    private lazy var apiURL: URL? = {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "generativelanguage.googleapis.com"
        components.path = "/v1beta/models/\(modelName):generateContent"
        components.queryItems = [URLQueryItem(name: "key", value: apiKey)]
        return components.url
    }()

    enum GeminiError: Error, LocalizedError {
        case invalidURL
        case imageDataConversionFailed
        case requestEncodingFailed(Error)
        case networkError(Error)
        case apiError(String)
        case decodingError(Error)
        case noContentGenerated
        
        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The API URL is invalid."
            case .imageDataConversionFailed:
                return "Failed to convert image to data."
            case .requestEncodingFailed(let error):
                return "Failed to encode the request payload: \(error.localizedDescription)"
            case .networkError(let error):
                return "A network error occurred: \(error.localizedDescription)"
            case .apiError(let message):
                return "The API returned an error: \(message)"
            case .decodingError(let error):
                return "Failed to decode the API response: \(error.localizedDescription)"
            case .noContentGenerated:
                return "The model did not generate any content."
            }
        }
    }
    
    func analyzeImage(_ image: UIImage) async -> Result<ProductInfo, GeminiError> {
        guard let url = apiURL else {
            return .failure(.invalidURL)
        }
        
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return .failure(.imageDataConversionFailed)
        }
        
        let prompt = createPrompt()
        let requestPayload = createRequestPayload(prompt: prompt, imageData: imageData)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestPayload)
        } catch {
            return .failure(.requestEncodingFailed(error))
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let errorBody = String(data: data, encoding: .utf8) ?? "No error body"
                return .failure(.apiError("HTTP Status \((response as? HTTPURLResponse)?.statusCode ?? 0). Details: \(errorBody)"))
            }
            
            let geminiResponse = try JSONDecoder().decode(GeminiAPIResponse.self, from: data)
            
            if let blockReason = geminiResponse.promptFeedback?.blockReason {
                return .failure(.apiError("Request blocked due to: \(blockReason)"))
            }
            
            guard let textContent = geminiResponse.candidates?.first?.content.parts.first?.text else {
                return .failure(.noContentGenerated)
            }
            
            return parseProductInfo(from: textContent)
            
        } catch let error as DecodingError {
            return .failure(.decodingError(error))
        } catch {
            return .failure(.networkError(error))
        }
    }
    
    private func createPrompt() -> String {
        return """
        Analyze the provided image of a food product label. Your task is to extract three pieces of information and return them ONLY as a valid JSON object.

        1.  **Product Name**: Extract the primary name of the product. If the name is in Russian, Ukrainian, or another language, translate it to its common English equivalent. If a name cannot be determined, use the string "Unknown Product".
        2.  **Expiration Date**: Find the expiration date. Parse any common date format (e.g., "DD.MM.YYYY", "MM/DD/YY", "DD MMM YYYY") and convert it strictly to "YYYY-MM-DD" format. If only a month and year are visible (e.g., "DEC 2024"), use the last day of that month (e.g., "2024-12-31"). If no date can be found, this field should be null.
        3.  **Storage Notes**: Provide a brief, helpful storage recommendation for this type of product. For example, for milk, a good note would be "Keep refrigerated. Best stored in the main body of the fridge, not the door." For bread, "Store in a cool, dry place. Avoid refrigeration." If no specific recommendation can be made, this field should be null.

        The JSON output MUST adhere to this structure:
        {
          "name": "string",
          "expiration_date": "string | null",
          "notes": "string | null"
        }

        Example 1 (Milk):
        {
          "name": "Milk",
          "expiration_date": "2024-12-25",
          "notes": "Keep refrigerated. Best stored in the main body of the fridge, not the door."
        }
        
        Example 2 (Bread, no date):
        {
          "name": "White Bread",
          "expiration_date": null,
          "notes": "Store in a cool, dry place. Avoid refrigeration to prevent it from going stale."
        }

        Do not include any text, explanations, or markdown formatting like ```json before or after the JSON object. Your entire response must be the raw JSON object itself.
        """
    }
    
    private func createRequestPayload(prompt: String, imageData: Data) -> GeminiAPIRequest {
        let textPart = Part(text: prompt)
        let imagePart = Part(inlineData: .init(mimeType: "image/jpeg", data: imageData.base64EncodedString()))
        
        let content = Content(parts: [textPart, imagePart])
        return GeminiAPIRequest(contents: [content])
    }
    
    private func parseProductInfo(from jsonString: String) -> Result<ProductInfo, GeminiError> {
        let cleanedString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "```json", with: "").replacingOccurrences(of: "```", with: "")
        
        guard let data = cleanedString.data(using: .utf8) else {
            return .failure(.decodingError(NSError(domain: "GeminiService", code: 1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert cleaned string to data."])))
        }
        
        let decoder = JSONDecoder()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        do {
            let decodedResponse = try decoder.decode(ProductInfoResponse.self, from: data)
            let productInfo = ProductInfo(
                name: decodedResponse.name,
                expirationDate: decodedResponse.expirationDate,
                notes: decodedResponse.notes
            )
            return .success(productInfo)
        } catch {
            return .failure(.decodingError(error))
        }
    }
}

private extension GeminiService {
    struct GeminiAPIRequest: Encodable {
        let contents: [Content]
    }
    
    struct Content: Encodable {
        let parts: [Part]
    }
    
    struct Part: Encodable {
        var text: String? = nil
        var inlineData: InlineData? = nil
    }
    
    struct InlineData: Encodable {
        let mimeType: String
        let data: String
    }
    
    struct GeminiAPIResponse: Decodable {
        let candidates: [Candidate]?
        let promptFeedback: PromptFeedback?
    }

    struct Candidate: Decodable {
        let content: ResponseContent
    }

    struct ResponseContent: Decodable {
        let parts: [ResponsePart]
    }

    struct ResponsePart: Decodable {
        let text: String?
    }
    
    struct PromptFeedback: Decodable {
        let blockReason: String?
    }
    
    struct ProductInfoResponse: Decodable {
        let name: String
        let expirationDate: Date?
        let notes: String?
        
        enum CodingKeys: String, CodingKey {
            case name, notes
            case expirationDate = "expiration_date"
        }
    }
}
