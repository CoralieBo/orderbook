# Contrat Intelligent OrderBook

## Vue d'ensemble

Le contrat `OrderBook` permet aux utilisateurs de créer, exécuter et suivre des ordres d'achat et de vente de tokens ERC20. Il fonctionne comme un carnet d'ordres décentralisé pour deux tokens ERC20 spécifiques (`token1` et `token2`). Les utilisateurs peuvent passer des ordres d'achat et de vente à des prix et montants spécifiques, et le contrat gère l'appariement et l'exécution de ces ordres.

## Fonctionnalités

1. **Création d'ordres** : Les utilisateurs peuvent créer des ordres d'achat ou de vente pour `token1` et `token2` en spécifiant le montant et le prix. Le contrat s'assure que l'utilisateur possède un solde suffisant avant de créer un ordre.

2. **Appariement d'ordres** : Si un ordre d'achat ou de vente entrant correspond à un ordre existant (c’est-à-dire que le prix et le montant correspondent), les ordres sont immédiatement exécutés et les tokens sont transférés entre les parties concernées.

3. **Historique des ordres** : Chaque ordre exécuté est enregistré dans un historique public des ordres, accessible à tous.

4. **Ordres en attente** : Les ordres non appariés restent dans le carnet d'ordres du contrat (achat ou vente) jusqu'à ce qu'ils soient appariés ou annulés.

## Composants du contrat

### 1. **Structure `Order`**
   - `trader` : Adresse de l'utilisateur ayant créé l'ordre.
   - `amount` : Le nombre de tokens dans l'ordre.
   - `price` : Le prix par token pour l'ordre.
   - `isBuyOrder` : Un booléen indiquant si l'ordre est un ordre d'achat (`true`) ou un ordre de vente (`false`).

### 2. **Variables d'état**
   - `token1` : Le premier token ERC20 utilisé dans le carnet d'ordres.
   - `token2` : Le deuxième token ERC20 utilisé dans le carnet d'ordres.
   - `buys` : Un tableau des ordres d'achat en attente.
   - `sells` : Un tableau des ordres de vente en attente.
   - `history` : Un tableau des ordres exécutés.
   - `orderCount` : Un compteur suivant le nombre total d'ordres créés.

### 3. **Événements**
   - `NewOrder` : Émis lorsqu'un nouvel ordre est créé.
   - `OrderFilled` : Émis lorsqu'un ordre est apparié et exécuté avec succès.

## Fonctions

### `constructor(IERC20 _token1, IERC20 _token2)`
Initialise le contrat avec les deux tokens ERC20 qui seront échangés.

### `createOrder(uint256 _amount, uint256 _price, bool _isBuyOrder)`
Crée un nouvel ordre (soit un ordre d'achat, soit un ordre de vente). Il valide les paramètres d'entrée et décide de créer un ordre d'achat ou de vente en fonction du flag `_isBuyOrder`.

### `createBuyOrder(uint256 _amount, uint256 _price)`
Gère la création des ordres d'achat. Si un ordre de vente correspondant est trouvé, il est exécuté immédiatement. Sinon, l'ordre d'achat est ajouté à la liste des achats en attente.

### `createSellOrder(uint256 _amount, uint256 _price)`
Gère la création des ordres de vente. Si un ordre d'achat correspondant est trouvé, il est exécuté immédiatement. Sinon, l'ordre de vente est ajouté à la liste des ventes en attente.

### `getBuys()`
Renvoie tous les ordres d'achat en attente.

### `getSells()`
Renvoie tous les ordres de vente en attente.

### `getHistory()`
Renvoie l'historique des ordres exécutés.
