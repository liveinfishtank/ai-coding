import XCTest
@testable import AnatoVision

final class RemoteAnatomyReviewClientTests: XCTestCase {
    override func tearDown() {
        MockURLProtocol.requestHandler = nil
        super.tearDown()
    }

    func testReviewResponseDecodesBase64Redline() throws {
        let data = """
        {
          "redlinedImageBase64": "cmVkbGluZQ==",
          "redlinedImageURL": null,
          "feedbackText": "Adjust the right shoulder perspective."
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(ReviewResponse.self, from: data)

        XCTAssertEqual(response.redlinedImageBase64, "cmVkbGluZQ==")
        XCTAssertNil(response.redlinedImageURL)
        XCTAssertEqual(response.feedbackText, "Adjust the right shoulder perspective.")
    }

    func testAnalyzePostsImageAndReturnsReviewResult() async throws {
        let expectedRedline = Data("redline".utf8)
        let responseBody = """
        {
          "redlinedImageBase64": "\(expectedRedline.base64EncodedString())",
          "redlinedImageURL": null,
          "feedbackText": "Move the elbow outward."
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.url?.path, "/v1/anatomy-reviews")
            XCTAssertEqual(request.timeoutInterval, 5)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Authorization"), "Bearer test-token")
            let body = try XCTUnwrap(request.bodyData)
            let json = try JSONSerialization.jsonObject(with: body) as? [String: Any]
            XCTAssertEqual(json?["imageBase64"] as? String, Data("image".utf8).base64EncodedString())

            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, responseBody)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let client = RemoteAnatomyReviewClient(
            baseURL: URL(string: "https://api.example.test")!,
            bearerToken: "test-token",
            session: session
        )

        let result = try await client.analyze(imageData: Data("image".utf8))

        XCTAssertEqual(result.redlinedImageData, expectedRedline)
        XCTAssertEqual(result.feedbackText, "Move the elbow outward.")
    }

    func testAnalyzeRequiresRedlineImage() async throws {
        let responseBody = """
        {
          "redlinedImageBase64": null,
          "redlinedImageURL": null,
          "feedbackText": "Feedback without an image."
        }
        """.data(using: .utf8)!

        MockURLProtocol.requestHandler = { request in
            let response = HTTPURLResponse(
                url: try XCTUnwrap(request.url),
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            return (response, responseBody)
        }

        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [MockURLProtocol.self]
        let session = URLSession(configuration: configuration)
        let client = RemoteAnatomyReviewClient(baseURL: URL(string: "https://api.example.test")!, session: session)

        do {
            _ = try await client.analyze(imageData: Data("image".utf8))
            XCTFail("Expected missing redline error.")
        } catch let error as AnatomyReviewError {
            XCTAssertEqual(error, .missingRedline)
        }
    }
}

private final class MockURLProtocol: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            XCTFail("Request handler was not set.")
            client?.urlProtocol(
                self,
                didFailWithError: NSError(
                    domain: "MockURLProtocol",
                    code: 1,
                    userInfo: [NSLocalizedDescriptionKey: "Request handler was not set."]
                )
            )
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

private extension URLRequest {
    var bodyData: Data? {
        if let httpBody {
            return httpBody
        }

        guard let stream = httpBodyStream else {
            return nil
        }

        stream.open()
        defer { stream.close() }

        var data = Data()
        let bufferSize = 1024
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        defer { buffer.deallocate() }

        while stream.hasBytesAvailable {
            let read = stream.read(buffer, maxLength: bufferSize)
            if read < 0 {
                return nil
            }
            if read == 0 {
                break
            }
            data.append(buffer, count: read)
        }
        return data
    }
}
