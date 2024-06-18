//
//  APISession.swift
//  HHSwift
//
//  Created by Michael on 2022/12/27.
//

import Foundation
import Alamofire
import RxSwift

public enum API {
    static public let baseURL_0 = URL(string: debug() ? "https://www.nmy.com/hh" : "https://www.nmy.com/hhss")!
    static public let baseURL_1 = URL(string: "https://api1.example.com")!
    static public let baseURL_2 = URL(string: "https://api2.example.com")!
}
enum APIString {
    static let AuthorizedUpgrade: String = debug() ? "https://jxcproapitest.ningmengyun.com" : ""
    static let ScanResult: String = debug() ? "https://jproapitest.ningmengyun.com" : ""
}

public enum APISessionError: Error {
    case networkError(error: Error, statusCode: Int)
    case invalidJSON
    case noData
}

public protocol APISession {
    associatedtype ReponseType: Codable
    func get(_ baseUrl: URL, path: String?, headers: HTTPHeaders, parameters: Parameters?) -> Observable<ReponseType>
    func post(_ baseUrl: URL, path: String?, headers: HTTPHeaders, parameters: Parameters?) -> Observable<ReponseType>
    func uploadImage(_ baseUrl: URL, path: String, image: UIImage, headers: HTTPHeaders) -> Observable<ReponseType>
    func request()
}

public extension APISession {
    var defaultHeaders: HTTPHeaders {
        let headers: HTTPHeaders = [
            "x-app-platform": "iOS",
            "x-app-version": "5.1.1",
            "x-os-version": UIDevice.current.systemVersion,
            "AsId": "100133941",
            "User-Agent": "HHiOSUser-Agent",
            "Authorization": "Bearer \(UserDefaults.standard.value(forKey: "access_token") ?? "")",
            "Content-Type": "application/json",
        ]
        return headers
    }
    
    //    var baseUrl: URL {
    //        return API.baseURL
    //    }
    
    func get(_ baseUrl: URL, path: String? = nil, headers: HTTPHeaders = [:], parameters: Parameters? = nil) -> Observable<ReponseType> {
        return request(baseUrl, path: path, method: .get, headers: headers, parameters: parameters, encoding: JSONEncoding.default)
    }
    
    func post(_ baseUrl: URL, path: String? = nil, headers: HTTPHeaders = [:], parameters: Parameters? = nil) -> Observable<ReponseType> {
        return request(baseUrl, path: path, method: .post, headers: headers, parameters: parameters, encoding: JSONEncoding.default)
    }
    
    func delete(_ baseUrl: URL, path: String? = nil, headers: HTTPHeaders = [:], parameters: Parameters? = nil) -> Observable<ReponseType> {
        return request(baseUrl, path: path, method: .delete, headers: headers, parameters: parameters, encoding: JSONEncoding.default)
    }
    
    func uploadImage(_ baseUrl: URL, path: String, image: UIImage, headers: HTTPHeaders) -> Observable<ReponseType> {
        return upload(baseUrl, path: path, image: image, headers: headers)
    }
    
    func request() {
        //AF命名空间，链式调用
        AF.request("http://59.110.112.58:9093/jxc_api/Product/GetById/100000020", method: .get, parameters: nil, encoding: URLEncoding.default, headers: defaultHeaders).response { response in
            debugPrint(response)
        }
    }
    
}

private extension APISession {
    func request(_ baseUrl: URL, path: String?, method: HTTPMethod, headers: HTTPHeaders, parameters: Parameters?, encoding: ParameterEncoding) -> Observable<ReponseType> {
        var url = baseUrl
        if let path = path, path.count > 0 {
            url = baseUrl.appendingPathComponent(path)
        }
        let allHeaders = HTTPHeaders(defaultHeaders.dictionary.merging(headers.dictionary) { $1 })
        
        return Observable.create { observer -> Disposable in
            let queue = DispatchQueue(label: "hh.app.api", qos: .background, attributes: .concurrent)
            // 网络请求
            let request = AF.request(url, method: method, parameters: parameters, encoding: encoding, headers: allHeaders, interceptor: nil)
                .validate()//.validate()：状态码是否在默认的可接受范围内200…299
                .responseJSON(queue: queue) { response in
                    debugPrint(response)
                    switch response.result {
                    case .success:
                        if let data = response.data, !data.isEmpty {
                            // 响应数据非空，进行序列化和处理
                            do {
                                let model = try JSONDecoder().decode(ReponseType.self, from: data)
                                observer.onNext(model)
                                observer.onCompleted()
                            } catch {
                                observer.onError(error)
                            }
                        } else {
                            // 响应数据为空或长度为零，进行错误处理
                            print("Response data is empty.")
                            observer.onError(response.error ?? APISessionError.noData)
                        }
                    case .failure(let error):
                        if let statusCode = response.response?.statusCode {
                            observer.onError(APISessionError.networkError(error: error, statusCode: statusCode))
                        } else {
                            observer.onError(error)
                        }
                    }
                }
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    // MARK: 上传图片
    func upload(_ baseUrl: URL, path: String, image: UIImage, headers: HTTPHeaders) -> Observable<ReponseType> {
        let url = path.count > 0 ? baseUrl.appendingPathComponent(path) : baseUrl
        let allHeaders = HTTPHeaders(defaultHeaders.dictionary.merging(headers.dictionary) { $1 })
        
        return Observable.create { observer -> Disposable in
            // 将图片转换为Data
            let imageData: Data! = image.jpegData(compressionQuality: 0.5)
            
            // 创建一个日期格式器
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyyMMddHHmmss"
            let dateString = dateFormatter.string(from: Date())
            let fileName = "image_\(dateString).jpg"
            
            // 使用Alamofire创建上传请求
            let request = AF.upload(multipartFormData: { multipartFormData in
                // 添加图片数据到表单数据中
                multipartFormData.append(imageData, withName: "file", fileName: fileName, mimeType: "image/jpeg")//"image/*"
                // 如果你还有其他的参数需要上传，可以继续添加到multipartFormData中
                // 例如：multipartFormData.append("value".data(using: .utf8)!, withName: "key")
            }, to: url, method: .post, headers: allHeaders)
                .uploadProgress { progress in
                    // 这里打印上传进度
                    print("Upload Progress: \(progress.fractionCompleted)")
                }
                .response { response in
                    // 这里处理上传完成后的响应
                    switch response.result {
                    case .success(let data):
                        if let data = data {
                            do {
                                let model = try JSONDecoder().decode(ReponseType.self, from: data)
                                observer.onNext(model)
                                observer.onCompleted()
                            } catch {
                                observer.onError(error)
                            }
                        } else {
                            // 响应数据为空或长度为零，进行错误处理
                            print("Response data is empty.")
                            observer.onError(response.error ?? APISessionError.noData)
                        }
                        print("Image uploaded successfully: \(String(describing: data))")
                    case .failure(let error):
                        print("Error uploading image: \(error)")
                        if let afError = error.asAFError, afError.isExplicitlyCancelledError {
                            // 这里处理显式取消的情况
                            print("Request was explicitly cancelled.")
                        } else {
                            // 其他错误处理
                            print("Error uploading image: \(error)")
                            observer.onError(error)
                        }
                    }
                }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
}


/// 将字典的键值对转换为key=value的形式，并且用&符号连接
func queryString(from dictionary: [String: Any]) -> String {
    //String数组
    var components: [String] = []
    for key in dictionary.keys.sorted() {
        if let value = dictionary[key] {
            // MARK: 对键和值进行URL编码
            /// 因为URL中的某些字符（如空格、特殊符号等）需要被转换为百分比编码（例如，空格被编码为%20），以确保它们在HTTP请求中传输时不会引起问题。
            let encodedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let encodedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            // 组装成key=value形式
            components.append("\(encodedKey)=\(encodedValue)")
        }
    }
    
    // 用&符号连接所有的key=value对
    return components.joined(separator: "&")
}

// 示例用法
func testQueryString() {
    let params: [String: Any] = [
        "name": "John Appleseed",
        "age": 25,
        "city": "New York"
    ]
    
    let queryString = queryString(from: params)
    print(queryString) // 输出: age=25&city=New%20York&name=John%20Appleseed
}

func createURL(with baseURL: String, path: String, parameters: [String: String]?) -> URL? {
    // 尝试构建URLComponents对象
    guard var components = URLComponents(string: baseURL) else { return nil }
    
    // 设置路径
    components.path = path
    
    if let parameters = parameters {
        // 将字典转换为URLQueryItem数组
        components.queryItems = parameters.map { URLQueryItem(name: $0.key, value: $0.value) }
    }
    
    // 返回构建好的URL
    return components.url
}

func createUrlTest() {
    // 使用示例
    let baseURL = "https://example.com"
    let path = "/api/items"
    let parameters = ["category": "books", "price": "10"]
    
    if let url = createURL(with: baseURL, path: path, parameters: parameters) {
        print(url) // 输出: https://example.com/api/items?category=books&price=10
        // 在这里你可以使用这个URL来进行网络请求等操作
    } else {
        print("无法创建URL")
    }
}

// MARK: URLSession
func sendPostRequest(urlString: String, requestBody: String, completion: @escaping (Result<[String: Any], Error>) -> Void) {
    // Create the URL
    guard let url = URL(string: urlString) else {
        print("Invalid URL")
        return
    }
    
    // Create the request object
    var request = URLRequest(url: url, timeoutInterval: Double.infinity)
    request.httpMethod = "POST"
    // Set the request headers
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    // Set the request body
    request.httpBody = requestBody.data(using: .utf8)
    
    // Create the URLSession configuration
    let sessionConfig = URLSessionConfiguration.default
    
    // Create the URLSession
    let session = URLSession(configuration: sessionConfig)
    
    // Create the data task
    let task = session.dataTask(with: request) { (data, response, error) in
        // Handle the response
        if let error = error {
            print("Error: \(error.localizedDescription)")
            completion(.failure(error))
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
                        completion(.success(responseDictionary))
                    }
                } catch {
                    print("Error parsing JSON: \(error)")
                    completion(.failure(error))
                }
            }
        }
    }
    
    // Start the task
    task.resume()
}

func testSendPostRequest() {
    sendPostRequest(urlString: "", requestBody: "") { result in
        switch result {
        case .success(let responseDict):
            print("Success: \(responseDict)")
        case .failure(let error):
            print("Failure: \(error.localizedDescription)")
        }
    }
}
