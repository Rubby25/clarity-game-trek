;; Define data structures
(define-map players 
  principal 
  {name: (string-ascii 32), 
   health: uint, 
   attack: uint, 
   defense: uint,
   experience: uint,
   level: uint,
   current-location: uint}
)

(define-map items 
  uint 
  {name: (string-ascii 32),
   power: uint,
   value: uint}
)

(define-map quests
  uint
  {name: (string-ascii 32),
   reward-xp: uint,
   required-level: uint,
   location: uint}
)

;; Constants
(define-constant err-player-exists (err u100))
(define-constant err-player-not-found (err u101))
(define-constant err-invalid-level (err u102))
(define-constant err-quest-not-found (err u103))
(define-constant err-wrong-location (err u104))
(define-constant exp-per-level u100)

;; Public functions
(define-public (create-player (name (string-ascii 32)) (health uint) (attack uint) (defense uint))
  (let ((player-exists (is-some (map-get? players tx-sender))))
    (if player-exists
      err-player-exists
      (ok (map-set players tx-sender {
        name: name,
        health: health,
        attack: attack,
        defense: defense,
        experience: u0,
        level: u1,
        current-location: u0
      }))
    )
  )
)

(define-public (move-location (new-location uint))
  (let ((player (map-get? players tx-sender)))
    (match player
      player-data (ok (map-set players tx-sender (merge player-data {current-location: new-location})))
      err-player-not-found
    )
  )
)

(define-public (add-quest (quest-id uint) (quest-name (string-ascii 32)) (reward uint) (req-level uint) (quest-location uint))
  (ok (map-set quests quest-id {
    name: quest-name,
    reward-xp: reward,
    required-level: req-level,
    location: quest-location
  }))
)

(define-public (start-quest (quest-id uint))
  (let (
    (player (map-get? players tx-sender))
    (quest (map-get? quests quest-id))
  )
    (match quest
      quest-data (
        (match player
          player-data (
            (if (and 
              (>= (get level player-data) (get required-level quest-data))
              (is-eq (get current-location player-data) (get location quest-data))
            )
              (ok (add-experience tx-sender (get reward-xp quest-data)))
              err-wrong-location
            )
          )
          err-player-not-found
        )
      )
      err-quest-not-found
    )
  )
)

(define-read-only (get-player-stats (player-id principal))
  (ok (map-get? players player-id))
)

;; Internal functions
(define-private (add-experience (player-id principal) (xp-amount uint))
  (let ((player (map-get? players player-id)))
    (match player
      player-data (
        let (
          (new-xp (+ (get experience player-data) xp-amount))
          (new-level (+ (get level player-data) (/ new-xp exp-per-level)))
        )
          (map-set players player-id (merge player-data {
            experience: new-xp,
            level: new-level
          }))
          (ok true)
      )
      err-player-not-found
    )
  )
)
