;; GlowNest Wellness Tracking Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-hours (err u101)) 
(define-constant err-invalid-quality (err u102))
(define-constant err-invalid-water (err u103))
(define-constant err-invalid-minutes (err u104))

;; Data Variables
(define-map UserData principal 
  {
    total-points: uint,
    sleep-logs: uint,
    hydration-logs: uint,
    mindfulness-logs: uint
  }
)

(define-map SleepData { user: principal, date: uint }
  {
    hours: uint,
    quality: uint
  }
)

(define-map HydrationData { user: principal, date: uint }
  {
    water-ml: uint
  }
)

(define-map MindfulnessData { user: principal, date: uint }
  {
    minutes: uint
  }
)

;; Private Functions
(define-private (get-today)
  (default-to u0 (get-block-info? time u0))
)

(define-private (initialize-user (user principal))
  (default-to
    { total-points: u0, sleep-logs: u0, hydration-logs: u0, mindfulness-logs: u0 }
    (map-get? UserData user)
  )
)

;; Public Functions
(define-public (log-sleep (hours uint) (quality uint))
  (let (
    (user-data (initialize-user tx-sender))
    (today (get-today))
  )
    (asserts! (and (>= hours u0) (<= hours u24)) err-invalid-hours)
    (asserts! (and (>= quality u0) (<= quality u100)) err-invalid-quality)
    
    (map-set SleepData { user: tx-sender, date: today }
      { hours: hours, quality: quality }
    )
    
    (map-set UserData tx-sender
      (merge user-data {
        total-points: (+ (get total-points user-data) u10),
        sleep-logs: (+ (get sleep-logs user-data) u1)
      })
    )
    (ok true)
  )
)

(define-public (log-hydration (water-ml uint))
  (let (
    (user-data (initialize-user tx-sender))
    (today (get-today))
  )
    (asserts! (> water-ml u0) err-invalid-water)
    
    (map-set HydrationData { user: tx-sender, date: today }
      { water-ml: water-ml }
    )
    
    (map-set UserData tx-sender
      (merge user-data {
        total-points: (+ (get total-points user-data) u5),
        hydration-logs: (+ (get hydration-logs user-data) u1)
      })
    )
    (ok true)
  )
)

(define-public (log-mindfulness (minutes uint))
  (let (
    (user-data (initialize-user tx-sender))
    (today (get-today))
  )
    (asserts! (> minutes u0) err-invalid-minutes)
    
    (map-set MindfulnessData { user: tx-sender, date: today }
      { minutes: minutes }
    )
    
    (map-set UserData tx-sender
      (merge user-data {
        total-points: (+ (get total-points user-data) u15),
        mindfulness-logs: (+ (get mindfulness-logs user-data) u1)
      })
    )
    (ok true)
  )
)

;; Read Only Functions
(define-read-only (get-sleep-data (user principal) (date uint))
  (map-get? SleepData { user: user, date: date })
)

(define-read-only (get-hydration-data (user principal) (date uint))
  (map-get? HydrationData { user: user, date: date })
)

(define-read-only (get-mindfulness-data (user principal) (date uint))
  (map-get? MindfulnessData { user: user, date: date })
)

(define-read-only (get-points (user principal))
  (get total-points (initialize-user user))
)
