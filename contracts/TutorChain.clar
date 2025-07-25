;; TutorChain - Academic tutoring session tracking and recognition platform
;; Version: 1.0.0

(define-data-var program-coordinator principal tx-sender)
(define-data-var total-tutoring-hours uint u0)
(define-data-var recognition-multiplier uint u25) ;; recognition points per hour
(define-data-var last-recognition-cycle uint u0)

(define-map tutor-contributions principal uint)
(define-map tutor-subjects principal (string-utf8 64))
(define-map subject-approvals (string-utf8 64) bool)

;; Error codes
(define-constant err-unauthorized-coordinator (err u1200))
(define-constant err-coordinator-already-exists (err u1201))
(define-constant err-invalid-hours (err u1202))
(define-constant err-no-recognition-due (err u1203))
(define-constant err-no-contributions (err u1204))
(define-constant err-invalid-subject (err u1205))
(define-constant err-subject-not-approved (err u1206))

;; Verify coordinator authorization
(define-private (is-program-coordinator (caller principal))
  (begin
    (asserts! (is-eq caller (var-get program-coordinator)) err-unauthorized-coordinator)
    (ok true)))

;; Initialize tutoring tracking program
(define-public (launch-tutoring-program (coordinator principal))
  (begin
    (asserts! (is-none (map-get? tutor-contributions coordinator)) err-coordinator-already-exists)
    (var-set program-coordinator coordinator)
    (ok "TutorChain program launched successfully")))

;; Approve subject for tutoring tracking
(define-public (approve-subject (subject-name (string-utf8 64)))
  (begin
    (try! (is-program-coordinator tx-sender))
    (asserts! (> (len subject-name) u0) err-invalid-subject)
    (map-set subject-approvals subject-name true)
    (ok "Subject approved for tutoring tracking")))

;; Register tutoring hours
(define-public (log-tutoring-hours (hours uint) (subject (string-utf8 64)))
  (begin
    (asserts! (> hours u0) err-invalid-hours)
    (asserts! (default-to false (map-get? subject-approvals subject)) err-subject-not-approved)
    
    (let ((current-hours (default-to u0 (map-get? tutor-contributions tx-sender))))
      (map-set tutor-contributions tx-sender (+ current-hours hours))
      (map-set tutor-subjects tx-sender subject)
      (var-set total-tutoring-hours (+ (var-get total-tutoring-hours) hours))
      (ok (+ current-hours hours)))))

;; Calculate recognition points
(define-public (calculate-recognition-points)
  (begin
    (try! (is-program-coordinator tx-sender))
    (let ((current-cycle (+ (var-get last-recognition-cycle) u1))
          (total-hours (var-get total-tutoring-hours)))
      (asserts! (> total-hours (var-get last-recognition-cycle)) err-no-recognition-due)
      
      (let ((new-recognition-points (* (var-get recognition-multiplier) total-hours)))
        (var-set last-recognition-cycle current-cycle)
        (ok new-recognition-points)))))

;; Claim tutoring recognition rewards
(define-public (claim-tutoring-recognition)
  (begin
    (let ((tutor-hours (default-to u0 (map-get? tutor-contributions tx-sender))))
      (asserts! (> tutor-hours u0) err-no-contributions)
      
      (let ((total-hours (var-get total-tutoring-hours))
            (recognition-points (* (var-get recognition-multiplier) tutor-hours))
            (contribution-percentage (/ (* tutor-hours u100000) total-hours)))
        
        (let ((final-recognition (/ (* contribution-percentage recognition-points) u100000)))
          (map-delete tutor-contributions tx-sender)
          (map-delete tutor-subjects tx-sender)
          (var-set total-tutoring-hours (- (var-get total-tutoring-hours) tutor-hours))
          (ok (+ tutor-hours final-recognition)))))))

;; Read-only functions
(define-read-only (get-tutoring-hours (tutor principal))
  (default-to u0 (map-get? tutor-contributions tutor)))

(define-read-only (get-tutor-subject (tutor principal))
  (map-get? tutor-subjects tutor))

(define-read-only (get-total-tutoring-hours)
  (var-get total-tutoring-hours))

(define-read-only (is-subject-approved (subject-name (string-utf8 64)))
  (default-to false (map-get? subject-approvals subject-name)))

(define-read-only (get-program-stats)
  {
    coordinator: (var-get program-coordinator),
    total-hours: (var-get total-tutoring-hours),
    recognition-multiplier: (var-get recognition-multiplier)
  })