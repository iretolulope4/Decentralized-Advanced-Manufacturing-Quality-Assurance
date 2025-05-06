;; Component Tracking Contract
;; Records parts used in production

(define-data-var last-component-id uint u0)

;; Component structure
(define-map components
  { component-id: uint }
  {
    part-number: (string-utf8 50),
    manufacturer: (string-utf8 100),
    batch-number: (string-utf8 50),
    timestamp: uint,
    added-by: principal
  }
)

;; Add a new component to the system
(define-public (add-component (part-number (string-utf8 50)) (manufacturer (string-utf8 100)) (batch-number (string-utf8 50)))
  (let
    (
      (new-id (+ (var-get last-component-id) u1))
    )
    (var-set last-component-id new-id)
    (map-set components
      { component-id: new-id }
      {
        part-number: part-number,
        manufacturer: manufacturer,
        batch-number: batch-number,
        timestamp: (unwrap-panic (get-block-info? time u0)),
        added-by: tx-sender
      }
    )
    (ok new-id)
  )
)

;; Get component details
(define-read-only (get-component (component-id uint))
  (map-get? components { component-id: component-id })
)

;; Get the total number of components
(define-read-only (get-component-count)
  (var-get last-component-id)
)
