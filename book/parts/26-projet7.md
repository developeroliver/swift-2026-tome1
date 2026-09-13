# Projet 7 — ⚡ Concurrent Data Engine {#projet-7}

Ce projet reprend le client réseau du Projet 5 et le transforme en un véritable moteur de traitement **concurrent** : au lieu de récupérer une tâche à la fois, il en récupère des dizaines **en parallèle**, en toute sécurité, grâce aux outils de la Partie 16 — `async`/`await`, `TaskGroup`, `actor` et `Sendable`.

Le code complet se trouve dans `projects/07-concurrent-data-engine/` du dépôt GitHub. Contrairement au Projet 5, ce package cible directement `swift-tools-version: 6.0`, sans aucun avertissement de concurrence stricte — l'objectif de ce projet est justement d'écrire du code nativement conforme à `Sendable` dès le départ, plutôt que de contourner la vérification.

### Des données `Sendable` dès la conception

```swift
enum APIError: Error, Sendable {
    case invalidURL
    case invalidResponse
    case decodingFailed
}

struct Todo: Sendable {
    let id: Int
    let title: String
    let isCompleted: Bool
}
```

`Todo` ne contient que des `let` de types eux-mêmes `Sendable` (`Int`, `String`, `Bool`) : sa conformité est automatique, mais la déclarer explicitement documente l'intention — cette valeur est conçue pour circuler en toute sécurité entre plusieurs tâches concurrentes (chapitre 57).

### Récupérer une tâche avec `async`/`await`

```swift
func fetchTodo(id: Int) async throws -> Todo {
    guard let url = URL(string: "https://jsonplaceholder.typicode.com/todos/\(id)") else {
        throw APIError.invalidURL
    }

    let (data, response) = try await URLSession.shared.data(from: url)

    guard let httpResponse = response as? HTTPURLResponse,
          (200...299).contains(httpResponse.statusCode)
    else {
        throw APIError.invalidResponse
    }

    guard
        let raw = try? JSONSerialization.jsonObject(with: data),
        let json = raw as? [String: Any],
        let id = json["id"] as? Int,
        let title = json["title"] as? String,
        let isCompleted = json["completed"] as? Bool
    else {
        throw APIError.decodingFailed
    }

    return Todo(id: id, title: title, isCompleted: isCompleted)
}
```

Comparez avec le Projet 5 : `URLSession.shared.data(from:)` (chapitre 53) remplace entièrement le trio closure `@escaping` + `DispatchSemaphore` — plus besoin d'attendre artificiellement une réponse asynchrone depuis du code synchrone, puisque tout le programme, cette fois, est pensé `async` de bout en bout.

### Un actor pour agréger les résultats en toute sécurité

Des dizaines de tâches vont écrire simultanément dans les mêmes statistiques — exactement le terrain d'une data race (chapitre 52) si on utilisait une `class` ordinaire :

```swift
actor Statistics {
    private var processed: [Todo] = []
    private var failures = 0

    func record(_ todo: Todo) {
        processed.append(todo)
    }

    func recordFailure() {
        failures += 1
    }

    var summary: String {
        let completed = processed.filter(\.isCompleted).count
        let pending = processed.count - completed
        return "Processed: \(processed.count) (✅ \(completed) done, ⏳ \(pending) pending) — ❌ \(failures) failed"
    }
}
```

Grâce à l'isolation de l'`actor` (chapitre 56), `processed.append(todo)` et `failures += 1` ne peuvent **jamais** s'exécuter simultanément pour deux appels concurrents — le compilateur l'impose, sans qu'aucun verrou manuel n'ait été écrit.

### Le moteur : un `TaskGroup` dynamique

```swift
func processConcurrently(ids: [Int], stats: Statistics) async {
    await withTaskGroup(of: Void.self) { group in
        for id in ids {
            group.addTask {
                do {
                    let todo = try await fetchTodo(id: id)
                    await stats.record(todo)
                } catch {
                    await stats.recordFailure()
                }
            }
        }
    }
}
```

`withTaskGroup` (chapitre 54) plutôt que `async let` : le nombre d'identifiants à traiter n'est connu qu'à l'exécution (fourni par l'utilisateur), pas fixé dans le code. Chaque tâche du groupe gère elle-même son échec individuel avec `do`/`catch` (chapitre 37) — une seule requête qui échoue ne doit jamais interrompre les autres.

### Mesurer le gain réel de la concurrence

```swift
let ids = Array(start...end)
let clock = ContinuousClock()
let elapsed = await clock.measure {
    await processConcurrently(ids: ids, stats: stats)
}
print("Processed \(ids.count) items concurrently in \(elapsed)")
```

`ContinuousClock().measure { ... }` chronomètre précisément un bloc de code asynchrone. Le résultat est spectaculaire : sur cette machine, traiter séquentiellement 40 requêtes (une par une, en attendant chaque réponse avant de lancer la suivante) a pris un peu plus de **5 secondes** ; les mêmes 40 requêtes, traitées en parallèle via `processConcurrently`, ont pris environ **0,1 seconde** — un gain d'un facteur 50, entièrement dû au fait que les 40 requêtes réseau attendent désormais **simultanément**, plutôt que les unes après les autres. Vos propres résultats varieront selon votre connexion, mais l'écart restera toujours de cet ordre de grandeur.

### Tester le programme

```bash
cd projects/07-concurrent-data-engine
swift run
```

```bash
printf "process 1 40\nstats\nquit\n" | swift run
```

<div class="exercise">
<div class="exercise-title">Exercice — pour aller plus loin</div>
Ajoutez une commande <code>process-sequential &lt;start&gt; &lt;end&gt;</code> qui traite les identifiants un par un avec une simple boucle <code>for</code> et <code>await</code> (sans <code>TaskGroup</code>), chronométrée de la même façon. Comparez vous-même les deux durées affichées pour la même plage d'identifiants, et vérifiez que <code>stats</code> reste cohérent quelle que soit la méthode utilisée — la sécurité apportée par l'<code>actor</code> ne dépend pas de la façon dont les tâches sont programmées.
</div>
