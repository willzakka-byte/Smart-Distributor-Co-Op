(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-member (err u101))
(define-constant err-already-member (err u102))
(define-constant err-insufficient-balance (err u103))
(define-constant err-invalid-amount (err u104))
(define-constant err-no-sales (err u105))
(define-constant err-already-distributed (err u106))
(define-constant err-invalid-region (err u107))
(define-constant err-unauthorized (err u108))

(define-data-var total-members uint u0)
(define-data-var treasury-balance uint u0)
(define-data-var current-period uint u0)
(define-data-var last-distribution-block uint u0)
(define-data-var min-sales-threshold uint u1000)

(define-map members 
    principal 
    {
        region: (string-ascii 50),
        total-sales: uint,
        join-block: uint,
        active: bool
    }
)

(define-map period-sales 
    {period: uint, member: principal}
    uint
)

(define-map period-totals 
    uint
    {
        total-sales: uint,
        distributed: bool,
        distribution-block: uint
    }
)

(define-map member-earnings
    principal
    uint
)

(define-map regional-stats
    (string-ascii 50)
    {
        total-sales: uint,
        member-count: uint
    }
)

(define-read-only (get-member (member principal))
    (map-get? members member)
)

(define-read-only (get-member-earnings (member principal))
    (default-to u0 (map-get? member-earnings member))
)

(define-read-only (get-period-sales (period uint) (member principal))
    (default-to u0 (map-get? period-sales {period: period, member: member}))
)

(define-read-only (get-period-info (period uint))
    (map-get? period-totals period)
)

(define-read-only (get-regional-stats (region (string-ascii 50)))
    (map-get? regional-stats region)
)

(define-read-only (get-treasury-balance)
    (var-get treasury-balance)
)

(define-read-only (get-current-period)
    (var-get current-period)
)

(define-read-only (get-total-members)
    (var-get total-members)
)

(define-read-only (is-member (account principal))
    (match (map-get? members account)
        member (get active member)
        false
    )
)

(define-public (join-coop (region (string-ascii 50)))
    (let
        (
            (caller tx-sender)
            (existing-member (map-get? members caller))
        )
        (asserts! (is-none existing-member) err-already-member)
        (asserts! (> (len region) u0) err-invalid-region)
        
        (map-set members caller {
            region: region,
            total-sales: u0,
            join-block: stacks-block-height,
            active: true
        })
        
        (map-set member-earnings caller u0)
        
        (match (map-get? regional-stats region)
            stats (map-set regional-stats region {
                total-sales: (get total-sales stats),
                member-count: (+ (get member-count stats) u1)
            })
            (map-set regional-stats region {
                total-sales: u0,
                member-count: u1
            })
        )
        
        (var-set total-members (+ (var-get total-members) u1))
        (ok true)
    )
)

(define-public (report-sales (amount uint))
    (let
        (
            (caller tx-sender)
            (member-data (unwrap! (map-get? members caller) err-not-member))
            (current-per (var-get current-period))
        )
        (asserts! (get active member-data) err-not-member)
        (asserts! (> amount u0) err-invalid-amount)
        
        (map-set members caller 
            (merge member-data {total-sales: (+ (get total-sales member-data) amount)})
        )
        
        (let
            (
                (current-sales (get-period-sales current-per caller))
                (period-info (default-to {total-sales: u0, distributed: false, distribution-block: u0} 
                    (map-get? period-totals current-per)))
            )
            (map-set period-sales {period: current-per, member: caller} (+ current-sales amount))
            (map-set period-totals current-per {
                total-sales: (+ (get total-sales period-info) amount),
                distributed: (get distributed period-info),
                distribution-block: (get distribution-block period-info)
            })
        )
        
        (match (map-get? regional-stats (get region member-data))
            stats (map-set regional-stats (get region member-data) {
                total-sales: (+ (get total-sales stats) amount),
                member-count: (get member-count stats)
            })
            true
        )
        
        (ok amount)
    )
)

(define-public (contribute-to-treasury (amount uint))
    (begin
        (asserts! (> amount u0) err-invalid-amount)
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        (var-set treasury-balance (+ (var-get treasury-balance) amount))
        (ok amount)
    )
)

(define-public (distribute-profits)
    (let
        (
            (current-per (var-get current-period))
            (period-info (unwrap! (map-get? period-totals current-per) err-no-sales))
            (treasury (var-get treasury-balance))
        )
        (asserts! (not (get distributed period-info)) err-already-distributed)
        (asserts! (> (get total-sales period-info) (var-get min-sales-threshold)) err-no-sales)
        (asserts! (> treasury u0) err-insufficient-balance)
        
        (map-set period-totals current-per {
            total-sales: (get total-sales period-info),
            distributed: true,
            distribution-block: stacks-block-height
        })
        
        (var-set last-distribution-block stacks-block-height)
        (var-set current-period (+ current-per u1))
        
        (ok true)
    )
)

(define-public (claim-earnings)
    (let
        (
            (caller tx-sender)
            (member-data (unwrap! (map-get? members caller) err-not-member))
            (last-period (- (var-get current-period) u1))
            (period-info (unwrap! (map-get? period-totals last-period) err-no-sales))
            (member-sales (get-period-sales last-period caller))
            (total-sales (get total-sales period-info))
            (treasury (var-get treasury-balance))
        )
        (asserts! (get active member-data) err-not-member)
        (asserts! (get distributed period-info) err-already-distributed)
        (asserts! (> member-sales u0) err-no-sales)
        (asserts! (> total-sales u0) err-no-sales)
        
        (let
            (
                (earnings (/ (* treasury member-sales) total-sales))
            )
            (asserts! (> earnings u0) err-invalid-amount)
            (try! (as-contract (stx-transfer? earnings tx-sender caller)))
            
            (var-set treasury-balance (- treasury earnings))
            (map-set member-earnings caller (+ (get-member-earnings caller) earnings))
            
            (ok earnings)
        )
    )
)

(define-public (advance-period)
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set current-period (+ (var-get current-period) u1))
        (ok (var-get current-period))
    )
)

(define-public (update-min-threshold (new-threshold uint))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (var-set min-sales-threshold new-threshold)
        (ok new-threshold)
    )
)

(define-public (deactivate-member (member principal))
    (let
        (
            (member-data (unwrap! (map-get? members member) err-not-member))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set members member (merge member-data {active: false}))
        (ok true)
    )
)

(define-public (reactivate-member (member principal))
    (let
        (
            (member-data (unwrap! (map-get? members member) err-not-member))
        )
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (map-set members member (merge member-data {active: true}))
        (ok true)
    )
)
