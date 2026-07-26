<?php
@session_start();
include('appconfig.php');

if (!isset($_POST['userid']) || $_POST['userid'] == '') {
    echo json_encode(["error" => "Username not found"]);
    exit;
}

$bid = $_POST['bid'];
$userid = $_POST['userid'];

// Date range filters
$date_filter = isset($_POST['date_filter']) ? $_POST['date_filter'] : 'today'; // today, week, month, year, all

$dt2 = date('Y-m-d'); // End date is always today for these relative filters
if ($date_filter == 'today') {
    $dt1 = date('Y-m-d');
} else if ($date_filter == 'week') {
    // start of week (monday)
    $dt1 = date('Y-m-d', strtotime('monday this week'));
} else if ($date_filter == 'month') {
    $dt1 = date('Y-m-01');
} else if ($date_filter == 'year') {
    $dt1 = date('Y-01-01');
} else {
    $dt1 = '2000-01-01'; // all time
}

$rw1 = mysqli_fetch_assoc(mysqli_query($con, "SELECT * FROM profile WHERE BID='".$bid."' AND id = '".$userid."' AND status = '' LIMIT 1"));

if ($rw1['id'] == '') {
    echo json_encode(["error" => "Invalid Username || Password"]);
    exit;
}

$response = array();

// 1. Key Metrics (Sales, Orders, Target)
$sqlSalesMetrics = mysqli_query($con, "
    SELECT 
        SUM(total) AS gross_sales, 
        SUM(total - rtotal) AS net_sales, 
        SUM(rtotal) AS returned_sales, 
        SUM(damnt) AS total_discounts,
        SUM(sqty) AS total_sqty,
        SUM(CAST(orqty AS DECIMAL(10,2))) AS total_orqty
    FROM sales 
    WHERE BID='".$rw1['BID']."' AND (dtd >= '".$dt1."' AND dtd <= '".$dt2."') AND bkby='".$rw1['id']."'
") OR die(mysqli_error($con));

$rowSalesMetrics = mysqli_fetch_assoc($sqlSalesMetrics);

// Get total unique active customers in this period from bookings
$sqlBookings = mysqli_query($con, "
    SELECT COUNT(DISTINCT acno) as active_cust, COUNT(DISTINCT id) as total_orders
    FROM bookings 
    WHERE BID='".$rw1['BID']."' AND DATE(dtd) >= '".$dt1."' AND DATE(dtd) <= '".$dt2."' AND bkby='".$rw1['id']."'
");
$rowBookings = mysqli_fetch_assoc($sqlBookings);

// 2. Financials (Accounts Receivable)
// Calculate Outstanding Balances for customers assigned to this user
$sqlFinancials = mysqli_query($con, "
    SELECT SUM(dr) as total_dr, SUM(cr) as total_cr 
    FROM profile 
    WHERE BID='".$rw1['BID']."' AND vendid='".$rw1['id']."' AND catgory='CUSTOMER'
");
$rowFinancials = mysqli_fetch_assoc($sqlFinancials);
$total_outstanding = (float)($rowFinancials['total_dr'] ?? 0) - (float)($rowFinancials['total_cr'] ?? 0);

// Calculate Total Collections from jv (Journal Vouchers)
$sqlCollections = mysqli_query($con, "
    SELECT SUM(amount) as total_collections
    FROM jv 
    WHERE BID='".$rw1['BID']."' AND vendid='".$rw1['id']."' AND dtd >= '".$dt1."' AND dtd <= '".$dt2."'
");
$rowCollections = $sqlCollections ? mysqli_fetch_assoc($sqlCollections) : null;
$total_collections = (float)($rowCollections['total_collections'] ?? 0);

// Calculate Gross Profit
$sqlProfit = mysqli_query($con, "
    SELECT SUM((s.rate - IFNULL(pur.rate, s.rate * 0.8)) * s.sqty) as gross_profit
    FROM sales s
    LEFT JOIN (
        SELECT prod_id, MAX(rate) as rate FROM purchase WHERE BID='".$rw1['BID']."' GROUP BY prod_id
    ) pur ON s.prod_id = pur.prod_id
    WHERE s.BID='".$rw1['BID']."' AND s.dtd >= '".$dt1."' AND s.dtd <= '".$dt2."' AND s.bkby='".$rw1['id']."'
");
$rowProfit = $sqlProfit ? mysqli_fetch_assoc($sqlProfit) : null;
$gross_profit = (float)($rowProfit['gross_profit'] ?? 0);
$profit_margin = 0;
$net_sales = (float)($rowSalesMetrics['net_sales'] ?? 0);
if ($net_sales > 0) {
    $profit_margin = ($gross_profit / $net_sales) * 100;
}

$fulfillment_rate = 0;
$total_sqty = (float)($rowSalesMetrics['total_sqty'] ?? 0);
$total_orqty = (float)($rowSalesMetrics['total_orqty'] ?? 0);
if ($total_orqty > 0) {
    $fulfillment_rate = ($total_sqty / $total_orqty) * 100;
} else if ($total_sqty > 0) {
    $fulfillment_rate = 100;
}

$response["metrics"] = array(
    "gross_sales" => (float)($rowSalesMetrics['gross_sales'] ?? 0),
    "net_sales" => $net_sales,
    "returned_sales" => (float)($rowSalesMetrics['returned_sales'] ?? 0),
    "total_orders" => (int)($rowBookings['total_orders'] ?? 0),
    "active_customers" => (int)($rowBookings['active_cust'] ?? 0),
    "fulfillment_rate" => (float)$fulfillment_rate,
    "profit_margin" => (float)$profit_margin,
    "target" => 0 // Fallback if actual targets exist elsewhere
);

$response["financials"] = array(
    "total_outstanding" => (float)$total_outstanding,
    "total_discounts" => (float)($rowSalesMetrics['total_discounts'] ?? 0),
    "total_collections" => (float)$total_collections
);

// 3. Sales Trend (Grouped by Date)
$sqlTrend = mysqli_query($con, "
    SELECT dtd as date, SUM(total) as gross_sales, SUM(total - rtotal) as net_sales, COUNT(DISTINCT acno) as orders 
    FROM sales 
    WHERE BID='".$rw1['BID']."' AND dtd >= '".$dt1."' AND dtd <= '".$dt2."' AND bkby='".$rw1['id']."' 
    GROUP BY dtd ORDER BY dtd ASC
");

$response["trend"] = array();
while ($row = mysqli_fetch_assoc($sqlTrend)) {
    array_push($response["trend"], array(
        "date" => $row['date'],
        "gross_sales" => (float)$row['gross_sales'],
        "net_sales" => (float)$row['net_sales'],
        "sales" => (float)$row['net_sales'], // keeping backward compatibility
        "orders" => (int)$row['orders']
    ));
}

if (count($response["trend"]) == 0) {
    $sqlTrendBook = mysqli_query($con, "
        SELECT DATE(dtd) as date, SUM(total) as gross_sales, SUM(total) as net_sales, COUNT(DISTINCT acno) as orders 
        FROM bookings 
        WHERE BID='".$rw1['BID']."' AND DATE(dtd) >= '".$dt1."' AND DATE(dtd) <= '".$dt2."' AND bkby='".$rw1['id']."' 
        GROUP BY DATE(dtd) ORDER BY DATE(dtd) ASC
    ");
    while ($row = mysqli_fetch_assoc($sqlTrendBook)) {
        array_push($response["trend"], array(
            "date" => $row['date'],
            "gross_sales" => (float)$row['gross_sales'],
            "net_sales" => (float)$row['net_sales'],
            "sales" => (float)$row['net_sales'],
            "orders" => (int)$row['orders']
        ));
    }
}

// 4. Top Products
$sqlProducts = mysqli_query($con, "
    SELECT s.prod_id, p.name, SUM(s.sqty) as qty, SUM(s.total) as gross_total, SUM(s.total - s.rtotal) as net_total, SUM(s.rtotal) as returned_total
    FROM sales s 
    LEFT JOIN products p ON s.prod_id = p.prod_id 
    WHERE s.BID='".$rw1['BID']."' AND s.dtd >= '".$dt1."' AND s.dtd <= '".$dt2."' AND s.bkby='".$rw1['id']."' 
    GROUP BY s.prod_id 
    ORDER BY net_total DESC LIMIT 5
");

$response["top_products"] = array();
while ($row = mysqli_fetch_assoc($sqlProducts)) {
    array_push($response["top_products"], array(
        "id" => $row['prod_id'],
        "name" => $row['name'] ? $row['name'] : 'Unknown Product',
        "qty" => (int)$row['qty'],
        "gross_total" => (float)$row['gross_total'],
        "total" => (float)$row['net_total'], // backward compatibility
        "returned_total" => (float)$row['returned_total']
    ));
}

// 5. Top Customers
$sqlCustomers = mysqli_query($con, "
    SELECT s.acno, c.acname, SUM(s.total) as gross_total, SUM(s.total - s.rtotal) as net_total, SUM(s.rtotal) as returned_total
    FROM sales s 
    LEFT JOIN profile c ON s.acno = c.id 
    WHERE s.BID='".$rw1['BID']."' AND s.dtd >= '".$dt1."' AND s.dtd <= '".$dt2."' AND s.bkby='".$rw1['id']."' 
    GROUP BY s.acno 
    ORDER BY net_total DESC LIMIT 5
");

$response["top_customers"] = array();
while ($row = mysqli_fetch_assoc($sqlCustomers)) {
    array_push($response["top_customers"], array(
        "id" => $row['acno'],
        "name" => $row['acname'] ? $row['acname'] : 'Unknown Customer',
        "gross_total" => (float)$row['gross_total'],
        "total" => (float)$row['net_total'], // backward compatibility
        "returned_total" => (float)$row['returned_total']
    ));
}

// 6. Area Performance (Bricks)
$sqlArea = mysqli_query($con, "
    SELECT c.brikid, br.acname, SUM(s.total - s.rtotal) as net_total 
    FROM sales s 
    LEFT JOIN profile c ON s.acno = c.id 
    LEFT JOIN brick br ON c.brikid = br.id 
    WHERE s.BID='".$rw1['BID']."' AND s.dtd >= '".$dt1."' AND s.dtd <= '".$dt2."' AND s.bkby='".$rw1['id']."' 
    GROUP BY c.brikid 
    ORDER BY net_total DESC
");

$response["area_performance"] = array();
while ($row = mysqli_fetch_assoc($sqlArea)) {
    array_push($response["area_performance"], array(
        "id" => $row['brikid'],
        "name" => $row['acname'] ? $row['acname'] : 'Unknown Area',
        "total" => (float)$row['net_total']
    ));
}

// 7. Expiry Alerts (from customerexpiry)
$sqlExpiry = mysqli_query($con, "
    SELECT e.prod_id, p.name, e.batno, e.exp_dtd, SUM(e.qty) as qty, SUM(e.total) as value, c.acname as customer_name
    FROM customerexpiry e
    LEFT JOIN products p ON e.prod_id = p.prod_id
    LEFT JOIN profile c ON e.acno = c.id
    WHERE e.BID='".$rw1['BID']."' AND e.bkby='".$rw1['id']."' 
      AND e.exp_dtd >= CURDATE() AND e.exp_dtd <= DATE_ADD(CURDATE(), INTERVAL 90 DAY)
    GROUP BY e.prod_id, e.batno, e.acno
    ORDER BY e.exp_dtd ASC
    LIMIT 10
");

$response["expiry_alerts"] = array();
if ($sqlExpiry) {
    while ($row = mysqli_fetch_assoc($sqlExpiry)) {
        array_push($response["expiry_alerts"], array(
            "product_name" => $row['name'] ? $row['name'] : 'Unknown Product',
            "batch_no" => $row['batno'] ? $row['batno'] : 'N/A',
            "expiry_date" => $row['exp_dtd'],
            "qty" => (int)$row['qty'],
            "value" => (float)$row['value'],
            "customer_name" => $row['customer_name'] ? $row['customer_name'] : 'Unknown Customer'
        ));
    }
}

// 8. Weekly Performance vs Company Average Threshold
$sqlCompanyAvg = mysqli_query($con, "
    SELECT AVG(daily_sales) as company_daily_avg FROM (
        SELECT dtd, bkby, SUM(total - rtotal) as daily_sales
        FROM sales
        WHERE BID='".$rw1['BID']."' AND dtd >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND bkby != ''
        GROUP BY dtd, bkby
    ) sub
");
$rowCompanyAvg = $sqlCompanyAvg ? mysqli_fetch_assoc($sqlCompanyAvg) : null;
$company_threshold = (float)($rowCompanyAvg['company_daily_avg'] ?? 0);

if ($company_threshold == 0) {
    $sqlCompanyAvgBook = mysqli_query($con, "
        SELECT AVG(daily_sales) as company_daily_avg FROM (
            SELECT DATE(dtd) as dtd, bkby, SUM(total) as daily_sales
            FROM bookings
            WHERE BID='".$rw1['BID']."' AND DATE(dtd) >= DATE_SUB(CURDATE(), INTERVAL 30 DAY) AND bkby != ''
            GROUP BY DATE(dtd), bkby
        ) sub
    ");
    $rowCompanyAvgBook = $sqlCompanyAvgBook ? mysqli_fetch_assoc($sqlCompanyAvgBook) : null;
    $company_threshold = (float)($rowCompanyAvgBook['company_daily_avg'] ?? 1500);
}

$monday = date('Y-m-d', strtotime('monday this week'));
$weekly_days = array();
$dayNames = array('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun');

for ($i = 0; $i < 7; $i++) {
    $curDate = date('Y-m-d', strtotime("$monday +$i days"));
    $dayName = $dayNames[$i];
    
    $sqlDaySales = mysqli_query($con, "
        SELECT SUM(total - rtotal) as day_sales FROM sales 
        WHERE BID='".$rw1['BID']."' AND dtd = '".$curDate."' AND bkby='".$rw1['id']."'
    ");
    $rowDaySales = $sqlDaySales ? mysqli_fetch_assoc($sqlDaySales) : null;
    $daySales = (float)($rowDaySales['day_sales'] ?? 0);
    
    if ($daySales == 0) {
        $sqlDayBook = mysqli_query($con, "
            SELECT SUM(total) as day_sales FROM bookings 
            WHERE BID='".$rw1['BID']."' AND DATE(dtd) = '".$curDate."' AND bkby='".$rw1['id']."'
        ");
        $rowDayBook = $sqlDayBook ? mysqli_fetch_assoc($sqlDayBook) : null;
        $daySales = (float)($rowDayBook['day_sales'] ?? 0);
    }
    
    $status = 'good';
    if ($company_threshold > 0) {
        if ($daySales > (1.15 * $company_threshold)) {
            $status = 'excellent';
        } else if ($daySales < (0.85 * $company_threshold)) {
            $status = 'poor';
        } else {
            $status = 'good';
        }
    }
    
    array_push($weekly_days, array(
        "day" => $dayName,
        "date" => $curDate,
        "sales" => $daySales,
        "status" => $status
    ));
}

$response["weekly_performance"] = array(
    "threshold" => $company_threshold,
    "days" => $weekly_days
);

echo json_encode($response);
?>
