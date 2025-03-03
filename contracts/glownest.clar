;; GlowNest Wellness Tracking Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-hours (err u101)) 
(define-constant err-invalid-quality (err u102))
(define-constant err-invalid-water (err u103))
(define-constant err-invalid-minutes (err u104))
(define-constant err-daily-limit-reached (err u105))

;; Point Values
(define-constant sleep-points u10)
(define-constant hydration-points u5)
(define-constant mindfulness-points u15)

;; Activity Limits
(define-constant max-water-ml u5000)
(define-constant max-mindfulness-minutes u180)

;; Data Variables
(define-map UserData principal 
  {
    total-points: uint,
    sleep-logs: uint,
    hydration-logs: uint,
    mindfulness-logs: uint,
    current-streak: uint,
    longest-streak: uint
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

(define-map WeeklyStats { user: principal, week: uint }
  {
    total-points: uint,
    activities-completed: uint
  }
)

;; Private Functions
(define-private (get-today)
  (default-to u0 (get-block-info? time u0))
)

(define-private (get-week)
  (/ (get-today) u604800)  ;; 7 days in seconds
)

(define-private (initialize-user (user principal))
  (default-to
    { 
      total-points: u0, 
      sleep-logs: u0, 
      hydration-logs: u0, 
      mindfulness-logs: u0,
      current-streak: u0,
      longest-streak: u0
    }
    (map-get? UserData user)
  )
)

(define-private (update-streak (user principal))
  (let (
    (user-data (initialize-user user))
    (new-streak (+ (get current-streak user-data) u1))
  )
    (map-set UserData user
      (merge user-data {
        current-streak: new-streak,
        longest-streak: (if (> new-streak (get longest-streak user-data))
          new-streak
          (get longest-streak user-data)
        )
      })
    )
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
        total-points: (+ (get total-points user-data) sleep-points),
        sleep-logs: (+ (get sleep-logs user-data) u1)
      })
    )
    (update-streak tx-sender)
    (ok true)
  )
)

;; [Rest of the contract implementation follows with similar enhancements]
