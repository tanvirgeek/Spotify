//
//  AuthManager.swift
//  Spotify
//
//  Created by Tanvir Alam on 24/2/24.
//

import Foundation

final class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    struct Constants {
        static let clientId = "db1f4a832cb644a2addddb5300c89d77"
        static let clientSecret = "5b5f8758253d4f538c2ae9dc817ae6ab"
        static let tokenAPIurl = "https://accounts.spotify.com/api/token"
    }
    
    var isSignedIn: Bool {
        return accessToken != nil
    }
    
    public var signInUrl: URL? {
        let scope = "user-read-private"
        let redirectURL = "https://www.iosacademy.io"
        let base = "https://accounts.spotify.com/authorize"
        let string = "\(base)?response_type=code&client_id=\(Constants.clientId)&scope=\(scope)&redirect_uri=\(redirectURL)&show_dialog=TRUE"
        return URL(string: string)
    }
    
    private var accessToken: String? {
        return UserDefaults.standard.string(forKey: "access_token")
    }

    private var refreshToken: String? {
        return UserDefaults.standard.string(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }

    private var shouldRefreshToken: Bool {
        return false
    }
    
    public func exchangeCodeForTokens(code: String, completion: @escaping ((Bool)->Void)) {
        // GET Token
        guard let url = URL(string: Constants.tokenAPIurl) else {
            return
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: "https://www.iosacademy.io")
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = components.query?.data(using: .utf8)
        
        let basicToken = Constants.clientId+":"+Constants.clientSecret
        let data = basicToken.data(using: .utf8)
        guard let base64String = data?.base64EncodedString() else {
            print("Failure to get base64")
            completion(false)
            return
        }
        
        request.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data, error == nil else {
                completion(false)
                return
            }
            
            do {
                let result = try JSONDecoder().decode(AuthModel.self, from: data)
                self?.cacheToken(result: result)
                completion(true)
            } catch {
                print(error.localizedDescription)
                completion(false)
            }
        }
        
        task.resume()
    }
    
    public func refreshAccessToken() {
        
    }
    
    private func cacheToken(result: AuthModel) {
        UserDefaults.standard.setValue(result.access_token, forKey: "access_token")
        UserDefaults.standard.setValue(result.refresh_token, forKey: "refresh_token")
        if let timeInterval = TimeInterval(result.expires_in) {
            UserDefaults.standard.setValue(Date().addingTimeInterval(timeInterval), forKey: "expirationDate")
        }
    }
}
