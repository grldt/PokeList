//
//  PokemonDetailViewController.swift
//  PokeList
//
//  Created by Gerald Stephanus on 15/12/22.
//

import UIKit

class PokemonDetailViewController: UIViewController {
    
    @IBOutlet weak var pokemonName: UILabel!
    @IBOutlet weak var pokemonTypes: UILabel!
    @IBOutlet weak var pokemonMoves: UILabel!
    @IBOutlet weak var pokemonImage: UIImageView!
    
    var pokemonID = 0
    var pokemon: PokemonDetail?
    var personalID = 0
    var personalPokemons: [PokemonDetail] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if(pokemonID == 0) {
            getPersonalPokemons()
            
            pokemon = personalPokemons[personalID]
            
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Release", style: .plain, target: self, action: #selector(releasePokemon))
            showPokemon()
        } else {
            getPokemon {
                print("pokemon acquired")
            }
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Catch", style: .plain, target: self, action: #selector(catchPokemon))
        }
    }
    
    func getPersonalPokemons() {
        if let savedPokemons = UserDefaults.standard.object(forKey: "savedpokemons") as? Data {
            let decoder = JSONDecoder()
            if let loadedPokemons = try? decoder.decode([PokemonDetail].self, from: savedPokemons) {
                personalPokemons = loadedPokemons
            }
        }
    }
    
    @objc func releasePokemon() {
        let alert = UIAlertController(title: "Release Pokemon", message: "Do you want to release this Pokemon?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Release", style: .destructive, handler: { [weak self] (_) in
            var saved: [PokemonDetail] = []
            
            if let savedPokemons = UserDefaults.standard.object(forKey: "savedpokemons") as? Data {
                let decoder = JSONDecoder()
                if let loadedPokemons = try? decoder.decode([PokemonDetail].self, from: savedPokemons) {
                    saved = loadedPokemons
                }
            }
            
            
            if let pid = self?.personalID {
                print("after: \(saved.count)")
                if let encoded = try? JSONEncoder().encode(saved) {
                    let defaults = UserDefaults.standard
                    defaults.set(encoded, forKey: "savedpokemons")
                }
            }
            
            
            
            
        }))
        present(alert, animated: true)
    }
    
    @objc func catchPokemon() {
        if(Int.random(in: 0..<2) < 1) {
            let alert = UIAlertController(title: "Pokemon Ran Away!", message: "You failed to catch the Pokemon", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
        } else {
            let alert = UIAlertController(title: "Pokemon Caught!", message: "Name your new Pokemon!", preferredStyle: .alert)
            alert.addTextField { field in
                field.placeholder = "Enter nickname"
            }
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] (_) in
                if let field = alert.textFields?.first {
                    if let text = field.text, !text.isEmpty {
                        if let savedPokemons = UserDefaults.standard.object(forKey: "savedpokemons") as? Data {
                            let decoder = JSONDecoder()
                            if let loadedPokemons = try? decoder.decode([PokemonDetail].self, from: savedPokemons) {
                                self!.personalPokemons = loadedPokemons
                            }
                        }
                        
                        self?.pokemon?.nickname = text
                        self?.personalPokemons.append((self?.pokemon)!)
                        
                        if let encoded = try? JSONEncoder().encode(self!.personalPokemons) {
                            let defaults = UserDefaults.standard
                            defaults.set(encoded, forKey: "savedpokemons")
                        }
                    }
                }
            }))
            present(alert, animated: true)
        }
    }
    
    func showPokemon() {
        if let monster = pokemon {
            if let nick = monster.nickname {
                pokemonName.text = "\(nick) (\(monster.name.capitalized))"
            } else {
                pokemonName.text = monster.name.capitalized
            }
            
            var typeText = ""
            
            for (index, type) in monster.types.enumerated() {
                typeText.append(type.type.name.capitalized)
                if (index + 1 != monster.types.count) {
                    typeText.append(", ")
                }
            }
            
            pokemonTypes.text = typeText
            pokemonTypes.numberOfLines = 0
            pokemonTypes.sizeToFit()
            
            var moveText = ""
            
            for (index, move) in monster.moves.enumerated() {
                moveText.append(move.move.name.capitalized)
                if (index + 1 != monster.moves.count) {
                    moveText.append(", ")
                }
            }
            
            pokemonMoves.text = moveText
            pokemonMoves.numberOfLines = 0
            pokemonMoves.sizeToFit()
            pokemonMoves.lineBreakMode = .byWordWrapping
            pokemonImage.fromURL(imgurl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(monster.id).png")
        }
    }
    
    func getPokemon(completed: @escaping () -> ()) {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(pokemonID)")
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if error == nil {
                do {
                    self.pokemon = try JSONDecoder().decode(PokemonDetail.self, from: data!)
                    
                    DispatchQueue.main.async {
                        self.showPokemon()
                        completed()
                    }
                } catch {
                    print("error getting API data")
                }
            }
        }.resume()
    }
}

