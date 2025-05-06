;; Testing Protocol Contract
;; Manages quality verification procedures

(define-data-var last-protocol-id uint u0)
(define-data-var last-test-result-id uint u0)

;; Testing protocol structure
(define-map testing-protocols
  { protocol-id: uint }
  {
    name: (string-utf8 100),
    description: (string-utf8 500),
    version: (string-utf8 20),
    created-by: principal,
    created-at: uint
  }
)

;; Test results structure
(define-map test-results
  { result-id: uint }
  {
    product-id: uint,
    protocol-id: uint,
    passed: bool,
    notes: (string-utf8 500),
    tester: principal,
    timestamp: uint
  }
)

;; Add a new testing protocol
(define-public (add-testing-protocol
                (name (string-utf8 100))
                (description (string-utf8 500))
                (version (string-utf8 20)))
  (let
    (
      (new-id (+ (var-get last-protocol-id) u1))
    )
    (var-set last-protocol-id new-id)
    (map-set testing-protocols
      { protocol-id: new-id }
      {
        name: name,
        description: description,
        version: version,
        created-by: tx-sender,
        created-at: (unwrap-panic (get-block-info? time u0))
      }
    )
    (ok new-id)
  )
)

;; Record test result
(define-public (record-test-result
                (product-id uint)
                (protocol-id uint)
                (passed bool)
                (notes (string-utf8 500)))
  (let
    (
      (new-id (+ (var-get last-test-result-id) u1))
    )
    (var-set last-test-result-id new-id)
    (map-set test-results
      { result-id: new-id }
      {
        product-id: product-id,
        protocol-id: protocol-id,
        passed: passed,
        notes: notes,
        tester: tx-sender,
        timestamp: (unwrap-panic (get-block-info? time u0))
      }
    )
    (ok new-id)
  )
)

;; Get testing protocol
(define-read-only (get-testing-protocol (protocol-id uint))
  (map-get? testing-protocols { protocol-id: protocol-id })
)

;; Get test result
(define-read-only (get-test-result (result-id uint))
  (map-get? test-results { result-id: result-id })
)
