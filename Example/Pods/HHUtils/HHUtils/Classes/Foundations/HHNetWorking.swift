//
//  HHNetWorking.swift
//  HHObjectiveCDemo
//
//  Created by Michael on 2023/5/16.
//

import Foundation

func makePOSTRequest() {
    // Create the URL
    guard let url = URL(string: "https://api.example.com/endpoint") else {
        print("Invalid URL")
        return
    }
    
    // Create the request object
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    // Set the request headers
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    // Set the request body
    let requestBodyString = "This is the request body string."
    request.httpBody = requestBodyString.data(using: .utf8)
    
    // Create the URLSession configuration
    let sessionConfig = URLSessionConfiguration.default
    
    // Create the URLSession
    let session = URLSession(configuration: sessionConfig)
    
    // Create the data task
    let task = session.dataTask(with: request) { (data, response, error) in
        // Handle the response
        if let error = error {
            print("Error: \(error.localizedDescription)")
            return
        }
        
        if let httpResponse = response as? HTTPURLResponse {
            print("Status code: \(httpResponse.statusCode)")
            
            if let responseData = data, let responseString = String(data: responseData, encoding: .utf8) {
                print("Response: \(responseString)")
                
                do {
                    // Parse the response data into a dictionary
                    if let responseDictionary = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                        print("Response: \(responseDictionary)")
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                }
            }
        }
    }
    
    // Start the task
    task.resume()
}
