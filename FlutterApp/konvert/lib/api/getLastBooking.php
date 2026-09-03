<?php
@session_start();
if (!isset($con)) {
    include('appconfig.php');
}

header('Content-Type: application/json; charset=utf-8');

// 1. Validate required parameters
if (!isset($_POST['bid']) || empty($_POST['bid'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Branch ID (bid) is required"
    ]);
    exit;
}

if (!isset($_POST['custid']) || empty($_POST['custid'])) {
    echo json_encode([
        "status" => "error",
        "message" => "Customer ID (custid) is required"
    ]);
    exit;
}

$bid = mysqli_real_escape_string($con, $_POST['bid']);
$custid = mysqli_real_escape_string($con, $_POST['custid']);
$userid = isset($_POST['userid']) ? mysqli_real_escape_string($con, $_POST['userid']) : '';

// 2. Optional user verification
if (!empty($userid)) {
    $userQuery = mysqli_query($con, "SELECT id FROM profile WHERE BID='$bid' AND id='$userid' AND status='' LIMIT 1");
    if (!$userQuery || mysqli_num_rows($userQuery) == 0) {
        echo json_encode([
            "status" => "error",
            "message" => "User authentication failed"
        ]);
        exit;
    }
}

// 3. Find the most recent booking invoice for this customer
$lastOrderQuery = mysqli_query($con, "
    SELECT purno, dtd, timespan, sdtd, bkby 
    FROM bookings 
    WHERE BID='$bid' AND acno='$custid' 
    ORDER BY dtd DESC, sdtd DESC, purno DESC 
    LIMIT 1
");

if (!$lastOrderQuery || mysqli_num_rows($lastOrderQuery) == 0) {
    echo json_encode([
        "status" => "empty",
        "message" => "No previous bookings found for this customer",
        "booking" => null
    ]);
    exit;
}

$lastOrderRow = mysqli_fetch_assoc($lastOrderQuery);
$latestPurno = $lastOrderRow['purno'];
$bookingDate = $lastOrderRow['dtd'];
$bookingTime = !empty($lastOrderRow['timespan']) ? $lastOrderRow['timespan'] : date('H:i', strtotime($lastOrderRow['sdtd']));
$bookedBy = $lastOrderRow['bkby'];

// 4. Fetch customer profile information
$custQuery = mysqli_query($con, "SELECT id, acname, vendid, ad1, phone FROM profile WHERE BID='$bid' AND id='$custid' LIMIT 1");
$custRow = mysqli_fetch_assoc($custQuery);
$customerName = $custRow ? trim($custRow['acname'] . ' ' . $custRow['vendid']) : "Customer #$custid";

// 5. Fetch all products/items in this last booking invoice
$itemsQuery = mysqli_query($con, "
    SELECT 
        b.prod_id,
        COALESCE(p.name, CONCAT('Product #', b.prod_id)) AS prod_name,
        COALESCE(p.pack, '') AS pack_size,
        b.qty,
        b.bns AS bonus,
        b.rate AS price,
        b.dper AS discount,
        b.total AS line_total
    FROM bookings b
    LEFT JOIN products p ON (b.prod_id = p.prod_id AND (p.BID='$bid' OR p.BID IS NULL))
    WHERE b.BID='$bid' AND b.acno='$custid' AND b.purno='$latestPurno'
    ORDER BY b.prod_id ASC
");

$items = array();
$grandTotal = 0.0;
$totalQty = 0;

if ($itemsQuery) {
    while ($item = mysqli_fetch_assoc($itemsQuery)) {
        $qty = (int)$item['qty'];
        $price = (float)$item['price'];
        $bonus = (float)$item['bonus'];
        $discount = (float)$item['discount'];
        $lineTotal = (float)$item['line_total'];

        // Fallback line total calculation if missing
        if ($lineTotal <= 0 && $price > 0 && $qty > 0) {
            $discountAmount = ($price * $qty * $discount) / 100.0;
            $lineTotal = ($price * $qty) - $discountAmount + $bonus;
        }

        $grandTotal += $lineTotal;
        $totalQty += $qty;

        $items[] = array(
            "prod_id"     => (string)$item['prod_id'],
            "prod_name"   => (string)$item['prod_name'],
            "pack_size"   => (string)$item['pack_size'],
            "qty"         => $qty,
            "bonus"       => $bonus,
            "price"       => $price,
            "discount"    => $discount,
            "line_total"  => round($lineTotal, 2)
        );
    }
}

echo json_encode(array(
    "status" => "success",
    "booking" => array(
        "invoice_no"     => (int)$latestPurno,
        "customer_id"    => (int)$custid,
        "customer_name"  => $customerName,
        "booking_date"   => (string)$bookingDate,
        "booking_time"   => (string)$bookingTime,
        "total_items"    => count($items),
        "total_qty"      => $totalQty,
        "grand_total"    => round($grandTotal, 2),
        "items"          => $items
    )
));
?>
