//
//  ViewController.swift
//  PokeList
//
//  Created by Gerald Stephanus on 15/12/22.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private let table: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    var personalList = false
    
    var buttonText: String {
        if(personalList) {
            return "All"
        }
        return "Personal"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonText, style: .plain, target: self, action: #selector(showPersonal))
        
        title = "PokeList"
        view.addSubview(table)
        table.dataSource = self
        table.delegate = self
        
        getPokemonList {
            self.table.reloadData()
            print("list acquired")
        }
        getPersonalPokemons()
        table.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getPokemonList {
            self.table.reloadData()
            print("list acquired")
        }
        getPersonalPokemons()
        table.reloadData()
    }
    
    @objc func showPersonal() {
        if(!personalPokemons.isEmpty) {
            personalList.toggle()
            table.reloadData()
        } else {
            let alert = UIAlertController(title: "You don't have any personal Pokemons", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .default))
            present(alert, animated: true)
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: buttonText, style: .plain, target: self, action: #selector(showPersonal))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        table.frame = view.bounds
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return personalList ? personalPokemons.count : pokemons.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "pokemon cell")
        
        if(personalList) {
            //get from userdefaults
            //let personalPokemon =
            let personalPokemon = personalPokemons[indexPath.row]
            if let nick = personalPokemon.nickname {
                cell.textLabel?.text = "\(nick) (\(personalPokemon.name.capitalized))"
            } else {
                cell.textLabel?.text = personalPokemon.name.capitalized
            }
            cell.imageView?.fromURL(imgurl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(personalPokemon.id).png")
            return cell
        }
        
        let pokemon = pokemons.results[indexPath.row]
        cell.textLabel?.text = pokemon.name.capitalized
        cell.imageView?.fromURL(imgurl: "https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/\(indexPath.row + 1).png")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "detailSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PokemonDetailViewController {
            if(personalList) {
                destination.personalID = table.indexPathForSelectedRow!.row
            } else {
                destination.pokemonID = table.indexPathForSelectedRow!.row + 1
            }
        }
    }
    
    var pokemons = PokemonList(results: [])
    var personalPokemons: [PokemonDetail] = []
    
    func getPersonalPokemons() {
        if let savedPokemons = UserDefaults.standard.object(forKey: "savedpokemons") as? Data {
            let decoder = JSONDecoder()
            if let loadedPokemons = try? decoder.decode([PokemonDetail].self, from: savedPokemons) {
                personalPokemons = loadedPokemons
            }
        }
    }

    func getPokemonList(completed: @escaping () -> ()) {
        let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=2000")
        
        URLSession.shared.dataTask(with: url!) { data, response, error in
            
            if error == nil {
                do {
                    self.pokemons = try JSONDecoder().decode(PokemonList.self, from: data!)
                    DispatchQueue.main.async {
                        completed()
                    }
                } catch {
                    print("error getting API data")
                }
                
                
            }
        }.resume()
    }

}

var imgCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    func fromURL(imgurl: String) {
        
        if let image = imgCache.object(forKey: imgurl as NSString) as? UIImage {
            self.image = image
            return
        }
        
        guard let url = URL(string: imgurl) else {
            return
        }
        
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}
