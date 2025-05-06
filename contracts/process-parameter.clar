;; Process Parameter Contract
;; Monitors manufacturing conditions

(define-data-var last-process-id uint u0)

;; Process parameters structure
(define-map process-parameters
  { process-id: uint }
  {
    product-id: uint,
    temperature: int,
    pressure: int,
    duration: uint,
    machine-id: (string-utf8 50),
    operator: principal,
    timestamp: uint
  }
)

;; Add process parameters
(define-public (record-process-parameters
                (product-id uint)
                (temperature int)
                (pressure int)
                (duration uint)
                (machine-id (string-utf8 50)))
  (let
    (
      (new-id (+ (var-get last-process-id) u1))
    )
    (var-set last-process-id new-id)
    (map-set process-parameters
      { process-id: new-id }
      {
        product-id: product-id,
        temperature: temperature,
        pressure: pressure,
        duration: duration,
        machine-id: machine-id,
        operator: tx-sender,
        timestamp: (unwrap-panic (get-block-info? time u0))
      }
    )
    (ok new-id)
  )
)

;; Get process parameters
(define-read-only (get-process-parameters (process-id uint))
  (map-get? process-parameters { process-id: process-id })
)

;; Get the total number of process records
(define-read-only (get-process-count)
  (var-get last-process-id)
)
