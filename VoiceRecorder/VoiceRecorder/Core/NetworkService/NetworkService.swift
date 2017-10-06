//
//  NetworkService.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 02/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import AFNetworking

// A service to work with the server API.

class NetworkService: AFHTTPSessionManager
{
    public static var timeoutInterval: TimeInterval = 15 // seconds
    
    // Singleton
    
    public static let sharedInstance: NetworkService =
    {
        var service = NetworkService(baseURL: nil)
        
        configureService(service)
        
        return service
    }()
    
    // Provide a default configuration for the AFHTTPSessionManager.
    
    private class func configureService(_ service: NetworkService)
    {
        // Override the default JSON response serializer.
        
        service.responseSerializer = AFHTTPResponseSerializer()
    }
}
