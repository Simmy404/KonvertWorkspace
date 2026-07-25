<?php
@session_start();
if (!isset($con)) {
  include("appconfig.php");
}

// Enable error reporting for the script to help debugging if needed
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

// Increase memory limit just in case, though streaming handles most of it
ini_set('memory_limit', '1024M'); 

$bid = isset($_GET['bid']) ? $_GET['bid'] : (isset($_POST['bid']) ? $_POST['bid'] : '28');

header('Content-Type: application/json');

// Start streaming the JSON response directly to the browser
echo "{\n";

// Helper function to fetch and stream table rows one by one
function streamTableData($con, $tableName, $query, $isLast = false) {
    echo '  "' . $tableName . '": ';
    
    // MYSQLI_USE_RESULT tells PHP to fetch rows one by one directly from the database server
    // rather than loading the entire result set into PHP memory all at once.
    $result = mysqli_query($con, $query, MYSQLI_USE_RESULT);
    
    if (!$result) {
        echo json_encode(array("error" => mysqli_error($con)));
    } else {
        echo "[\n";
        $first = true;
        while($row = mysqli_fetch_assoc($result)) {
            if (!$first) {
                echo ",\n";
            }
            // JSON encode just this single row and echo it immediately
            echo "    " . json_encode($row);
            $first = false;
        }
        echo "\n  ]";
        mysqli_free_result($result);
    }
    
    if (!$isLast) {
        echo ",\n";
    } else {
        echo "\n";
    }
}

// Fetch all data and stream directly to prevent memory exhaustion
streamTableData($con, 'profile', "SELECT * FROM profile WHERE BID='".$bid."'");
streamTableData($con, 'brick', "SELECT * FROM brick WHERE BID='".$bid."'");
streamTableData($con, 'bookings', "SELECT * FROM bookings WHERE BID='".$bid."'");
streamTableData($con, 'sales', "SELECT * FROM sales WHERE BID='".$bid."'");
streamTableData($con, 'purchase', "SELECT * FROM purchase WHERE BID='".$bid."'");
streamTableData($con, 'products', "SELECT * FROM products WHERE BID='".$bid."'");
streamTableData($con, 'sadjustment', "SELECT * FROM sadjustment WHERE BID='".$bid."'");
streamTableData($con, 'branch', "SELECT * FROM branch WHERE branch_id='".$bid."'", true); // true indicates this is the last item

echo "}\n";
?>
