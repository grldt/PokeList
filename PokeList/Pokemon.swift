//
//  Pokemon.swift
//  PokeList
//
//  Created by Gerald Stephanus on 15/12/22.
//

import Foundation

struct PokemonList: Decodable {
    let results: [result]

    struct result: Decodable {
        let name: String
    }
}

struct PokemonDetail: Decodable, Encodable {
    let id: Int
    let moves: [Move]
    let name: String
    let species: Species
    let types: [TypeElement]
    var nickname: String? = ""
}

struct Species: Decodable, Encodable {
    let name: String
    let url: String
}

struct Move: Decodable, Encodable {
    let move: Species
}

struct TypeElement: Decodable, Encodable {
    let slot: Int
    let type: Species
}

