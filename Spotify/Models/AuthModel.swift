//
//  AuthModel.swift
//  Spotify
//
//  Created by Tanvir Alam on 26/2/24.
//

import Foundation

struct AuthModel: Codable {
    let access_token: String
    let expires_in: Int
    let refresh_token: String?
    let scope: String
    let token_type: String
}
