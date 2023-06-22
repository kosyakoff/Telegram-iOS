//
//  ApiFetcher.swift
//  AccountContext
//
//  Created by МакБук on 22.06.2023.
//

import Foundation
import Postbox
import SwiftSignalKit
import MtProtoKit

class WorldTime: Codable {
    var datetime: String
    var unixtime: Int
    
    enum CodingKeys: String, CodingKey {
        case datetime = "datetime"
        case unixtime = "unixtime"
    }
}

public final class ApiFetcher {
        
    public static func fetchNetworkTime() -> Signal<Int?, NoError> {
        let worldTimeUrl = "http://worldtimeapi.org/api/timezone/Europe/Moscow"
        if let percentEncodedString = worldTimeUrl.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            
            let url = URL(string: percentEncodedString)
            return Signal { subscriber in
                let timeRequest = MTHttpRequestOperation.data(forHttpUrl: url)!
                let disposable = timeRequest.start(next: { next in
                    if let response = next as? MTHttpResponse {
                        
                        let data = response.data
                        let decoder = JSONDecoder()
                        if let currentTime = try? decoder.decode(WorldTime.self, from: data! as Data) {
                            subscriber.putNext(currentTime.unixtime)
                            subscriber.putCompletion()
                        }
                        else {
                            subscriber.putNext(nil)
                            subscriber.putCompletion()
                        }
                        
                    } else {
                        subscriber.putNext(nil)
                        subscriber.putCompletion()
                    }
                }, error: { _ in
                    subscriber.putNext(nil)
                    subscriber.putCompletion()
                }, completed: {
                })
                
                return ActionDisposable {
                    disposable?.dispose()
                }
            }
        } else {
            return .never()
        }
    }
    
}
