# Projet 5 — 🌐 API Client {#projet-5}

Ce projet construit un vrai client réseau — il effectue de véritables requêtes HTTP vers une API publique — en s'appuyant entièrement sur les Parties 8 à 10 : protocoles, associated types, generics, et closures `@escaping` (chapitre 15).

Le code complet se trouve dans `projects/05-api-client/` du dépôt GitHub. Il interroge [jsonplaceholder.typicode.com](https://jsonplaceholder.typicode.com), une API publique gratuite conçue pour les tests et les tutoriels.

> **Anticipation** — `JSONSerialization.jsonObject(with:)`, utilisée plus bas pour analyser la réponse du serveur, est une fonction *throwing* : elle peut échouer et signaler une erreur avec le mécanisme `throw` (Partie 11, juste après ce projet). En attendant de le voir en détail, `try?` transforme son résultat en un simple Optionnel — `nil` en cas d'échec, exactement comme les conversions déjà vues (`Int("abc")`) depuis la Partie 5.

> **Note technique** — ce projet cible `swift-tools-version: 5.10` plutôt que `6.0` dans son `Package.swift`. Swift 6 active par défaut une vérification stricte de la concurrence (`Sendable`, Partie 16) qui produirait ici des avertissements sur du code par ailleurs parfaitement correct, à propos d'un sujet non encore vu. Rien d'autre ne change : le code lui-même est du Swift 2026 tout à fait ordinaire.

### Modéliser les erreurs possibles avec un enum

```swift
enum APIError: Error {
    case invalidURL
    case requestFailed(String)
    case serverError(statusCode: Int)
    case invalidResponse
    case decodingFailed

    func describe() -> String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestFailed(let message):
            return "Request failed: \(message)"
        case .serverError(let statusCode):
            return "Server error (status \(statusCode))"
        case .invalidResponse:
            return "Invalid response from server"
        case .decodingFailed:
            return "Could not decode the response"
        }
    }
}
```

`APIError` se conforme au protocole `Error` — un protocole « marqueur » de la bibliothèque standard, sans aucune méthode ni property à implémenter. Cette seule conformance suffit à utiliser `APIError` comme type d'échec du `Result` qui suit ; le mécanisme complet de gestion d'erreurs (`throw`, `try`, `do`/`catch`) est le sujet de la Partie 11.

### Un protocole générique pour toute requête API

```swift
protocol APIRequest {
    associatedtype Response
    var url: URL? { get }
    func decode(_ data: Data) -> Result<Response, APIError>
}
```

`associatedtype Response` (chapitre 33) laisse chaque requête concrète préciser le type de donnée qu'elle renvoie — une requête de todo renverra un `Todo`, une requête d'utilisateur renverrait un `User`, sans jamais dupliquer le protocole lui-même.

`Result<Response, APIError>` — un enum générique de la bibliothèque standard, avec deux cases `.success(Response)` et `.failure(APIError)` — remplace ici le besoin d'un mécanisme `throws` : la fonction ne peut pas « planter silencieusement », le type de retour oblige l'appelant à traiter les deux issues possibles.

### Une requête concrète

```swift
struct Todo {
    let id: Int
    let title: String
    let isCompleted: Bool
}

struct FetchTodoRequest: APIRequest {
    let id: Int

    var url: URL? {
        URL(string: "https://jsonplaceholder.typicode.com/todos/\(id)")
    }

    func decode(_ data: Data) -> Result<Todo, APIError> {
        guard
            let raw = try? JSONSerialization.jsonObject(with: data),
            let json = raw as? [String: Any],
            let id = json["id"] as? Int,
            let title = json["title"] as? String,
            let isCompleted = json["completed"] as? Bool
        else {
            return .failure(.decodingFailed)
        }
        return .success(Todo(id: id, title: title, isCompleted: isCompleted))
    }
}
```

`decode` enchaîne cinq conditions dans un seul `guard` : la réponse doit être un JSON valide, qui doit être un objet (`[String: Any]`), et qui doit contenir les trois champs attendus avec les bons types (`as?`, chapitre 17). La moindre de ces cinq conditions qui échoue retombe sur `.decodingFailed` — un exemple concret de la programmation par `guard let` enchaînés déjà pratiquée aux Projets 3 et 4.

### Le client générique

```swift
struct APIClient {
    func send<Request: APIRequest>(
        _ request: Request,
        completion: @escaping (Result<Request.Response, APIError>) -> Void
    ) {
        guard let url = request.url else {
            completion(.failure(.invalidURL))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(.requestFailed(error.localizedDescription)))
                return
            }

            if let httpResponse = response as? HTTPURLResponse,
               !(200...299).contains(httpResponse.statusCode) {
                completion(.failure(.serverError(statusCode: httpResponse.statusCode)))
                return
            }

            guard let data else {
                completion(.failure(.invalidResponse))
                return
            }

            completion(request.decode(data))
        }.resume()
    }
}
```

`send<Request: APIRequest>` est une fonction générique (chapitre 35) contrainte à `APIRequest` : `APIClient` ne connaît **aucun** détail de `FetchTodoRequest` — il pourrait tout aussi bien recevoir une future `FetchUserRequest` sans être modifié d'une ligne. `Request.Response` (chapitre 36) référence l'associated type du paramètre générique, propagé jusqu'au type du `completion`.

`completion` est `@escaping` (chapitre 15) parce que `URLSession.shared.dataTask` exécute sa closure **après** que `send` soit déjà retournée — la requête réseau est asynchrone, la réponse arrive plus tard, sur un thread géré par `URLSession`.

### Attendre une closure asynchrone depuis un programme séquentiel

Ce programme est une simple ligne de commande, sans mécanisme dédié à l'attente d'opérations asynchrones (`async`/`await`, sujet de la Partie 16). `DispatchSemaphore` permet de bloquer l'exécution jusqu'à ce que la closure du réseau ait fini :

```swift
let semaphore = DispatchSemaphore(value: 0)
client.send(FetchTodoRequest(id: id)) { result in
    switch result {
    case .success(let todo):
        let status = todo.isCompleted ? "done" : "pending"
        print("✅ Todo #\(todo.id): \(todo.title) (\(status))")
    case .failure(let error):
        print("❌ \(error.describe())")
    }
    semaphore.signal()          // débloque le programme, une fois la réponse traitée
}
semaphore.wait()                  // bloque ici jusqu'au signal()
```

Cette technique reste utile pour de petits outils en ligne de commande, mais ne convient pas à une application avec interface graphique (elle bloquerait le thread principal, gelant l'affichage) — la Partie 16 introduira `async`/`await`, la solution moderne et idiomatique à ce même problème.

### Tester le programme

```bash
cd projects/05-api-client
swift run
```

```bash
printf "fetch 1\nfetch 999999\nquit\n" | swift run
```

`fetch 1` renvoie une vraie tâche depuis l'API ; `fetch 999999` dépasse la plage valide de l'API (1 à 200) et illustre la gestion d'un code de statut HTTP d'erreur (404).

<div class="exercise">
<div class="exercise-title">Exercice — pour aller plus loin</div>
Ajoutez une seconde requête <code>FetchUserRequest</code> ciblant <code>https://jsonplaceholder.typicode.com/users/{id}</code>, avec sa propre struct <code>User</code> (champs <code>id</code>, <code>name</code>, <code>email</code>) et sa propre logique de <code>decode</code>. Ajoutez une commande <code>user &lt;id&gt;</code> à la boucle principale, en réutilisant le même <code>APIClient.send</code> générique sans y changer une seule ligne.
</div>
