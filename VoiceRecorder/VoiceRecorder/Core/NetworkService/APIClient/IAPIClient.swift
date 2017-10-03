//
//  IAPIClient.swift
//  VoiceRecorder
//
//  Created by Ilya Rudometov on 03/10/2017.
//  Copyright © 2017 Ilya Rudometov. All rights reserved.
//

import Foundation

typealias APIClientProgressBlock = ((Progress) -> Void)
typealias APIClientFileCompletionBlock = ((_ fileData: Data?, _ error: Error?) -> Void)

// Base protocol for any API client.

protocol IAPIClient
{
    func uploadFile(atURL fileURL: URL, fileName: String, uploadProgress: APIClientProgressBlock?, completion: APIClientFileCompletionBlock?)
}
