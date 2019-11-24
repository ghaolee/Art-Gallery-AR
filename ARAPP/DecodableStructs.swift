//
//  DecodableStructs.swift
//  Final Project
//
//  Created by G Hao Lee on 11/24/19.
//  Copyright © 2019 ghao. All rights reserved.
//

import Foundation

struct Token: Decodable {
    let links: String?
    let expires_at: String
    let token: String
    let type: String
}

struct APISearchResult: Decodable {
    let total_count: Int
    let offset: Int
    let q: String
    let _embedded: Results
}

struct Results: Decodable {
    let results: [Poster]
}

struct Poster: Decodable {
    let type: String
    let title: String
    let _links: Thumbnail
}

struct Thumbnail: Decodable {
    let thumbnail: ImageLink
}

struct ImageLink: Decodable {
    let href: String
}

