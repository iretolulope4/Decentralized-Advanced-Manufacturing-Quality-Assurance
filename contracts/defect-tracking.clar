;; Defect Tracking Contract
;; Records identified issues and resolutions

(define-data-var last-defect-id uint u0)

;; Defect status enum
(define-constant STATUS-OPEN u1)
(define-constant STATUS-IN-PROGRESS u2)
(define-constant STATUS-RESOLVED u3)
(define-constant STATUS-CLOSED u4)

;; Defect structure
(define-map defects
  { defect-id: uint }
  {
    product-id: uint,
    description: (string-utf8 500),
    severity: uint,
    status: uint,
    reported-by: principal,
    reported-at: uint,
    resolved-at: (optional uint),
    resolution: (optional (string-utf8 500))
  }
)

;; Report a new defect
(define-public (report-defect
                (product-id uint)
                (description (string-utf8 500))
                (severity uint))
  (let
    (
      (new-id (+ (var-get last-defect-id) u1))
    )
    (var-set last-defect-id new-id)
    (map-set defects
      { defect-id: new-id }
      {
        product-id: product-id,
        description: description,
        severity: severity,
        status: STATUS-OPEN,
        reported-by: tx-sender,
        reported-at: (unwrap-panic (get-block-info? time u0)),
        resolved-at: none,
        resolution: none
      }
    )
    (ok new-id)
  )
)

;; Update defect status
(define-public (update-defect-status
                (defect-id uint)
                (new-status uint))
  (let
    (
      (defect (unwrap! (map-get? defects { defect-id: defect-id }) (err u1)))
    )
    (map-set defects
      { defect-id: defect-id }
      (merge defect { status: new-status })
    )
    (ok true)
  )
)

;; Resolve a defect
(define-public (resolve-defect
                (defect-id uint)
                (resolution (string-utf8 500)))
  (let
    (
      (defect (unwrap! (map-get? defects { defect-id: defect-id }) (err u1)))
      (current-time (unwrap-panic (get-block-info? time u0)))
    )
    (map-set defects
      { defect-id: defect-id }
      (merge defect
        {
          status: STATUS-RESOLVED,
          resolved-at: (some current-time),
          resolution: (some resolution)
        }
      )
    )
    (ok true)
  )
)

;; Get defect details
(define-read-only (get-defect (defect-id uint))
  (map-get? defects { defect-id: defect-id })
)
