//
//  NetworkService+API.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 02/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import Foundation
import FCFileManager

private struct API
{
    // Base URL
   
    // NOTE: use a public host name on the device.
    
    #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(watchOS) || os(tvOS))
    static var baseURL = "http://127.0.0.1:5000" // This is the IP address of my local web server.
    #else
    static var baseURL = "https://echoserver.fwd.wf"
    #endif
    
    // API Methods
    
    static let echo = "echo/"
}

// An extension of NetworkService to incapsulate API methods.

extension NetworkService: IAPIClient
{
    // MARK: - Build URL Request
    
    private class func urlWithAPIMethod(_ apiMethod: String) -> URL?
    {
        let trimmedAPIMethod = Utils.trimSlashPrefix(from: apiMethod)
        let urlString = API.baseURL + "/" + trimmedAPIMethod
        
        return URL(string: urlString)
    }
    
    private class func buildURLRequest(apiMethod: String) -> URLRequest?
    {
        if let url = urlWithAPIMethod(apiMethod)
        {
            return URLRequest(url: url, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData, timeoutInterval: timeoutInterval)
        }
        
        return nil
    }
    
    // MARK: - IAPIClient
    
    func uploadFile(atURL fileURL: URL, fileName: String, uploadProgress: APIClientProgressBlock?, completion: APIClientFileCompletionBlock?)
    {
        if let url = NetworkService.urlWithAPIMethod(API.echo)
        {
            self.post(url.absoluteString, parameters: nil, constructingBodyWith: { (formData) in
                
                try? formData.appendPart(withFileURL: fileURL, name: fileName)
                
            }, progress: uploadProgress, success: { (task, response) in
                
                completion?(response as? Data, nil)
                
            }, failure: { (task, error) in
                
                completion?(nil, error)
                
            })
        }
    }
}
