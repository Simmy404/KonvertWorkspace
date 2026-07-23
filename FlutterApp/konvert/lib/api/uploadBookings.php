<?php
@session_start();
include('appconfig.php');

if($_POST['bid']) 
{
  if($_POST['userid']) {
    $bid = $_POST['bid'];
    $userid = $_POST['userid'];
    $sdtd = date('Y-m-d H:i');
    $rw1 = mysqli_fetch_assoc(mysqli_query($con, "SELECT * FROM  profile WHERE BID='".$bid."' AND id='".$userid."' AND status = '' LIMIT 1"));
    if ($rw1) {
      if($_POST['jsonObj_bookings']) {
        $csvData = "";
        $sql = "INSERT IGNORE INTO bookings (dtd,sdtd,BID,UID,purno,acno,prod_id,qty,bns,rate,total,dper,latitude,longitude,bkby,timespan) VALUES ";
        $bookingsDataJson = json_decode($_POST['jsonObj_bookings'],true);
        if ( is_array($bookingsDataJson['bookings']) ) {
          $dtd = date('Y-m-d');
          $query_parts = array();
          foreach ($bookingsDataJson['bookings'] as $key => $record) {
            $booking_invoice  = $record['booking_invoice'];
            $booking_brikid   = $record['booking_brikid'];
            $booking_custid   = $record['booking_custid'];
            $booking_prodid   = $record['booking_prodid'];
            $booking_qty      = $record['booking_qty'];
            $booking_bonus    = $record['booking_bonus'];
            $booking_discount = $record['booking_discount'];
            $booking_price    = $record['booking_price'];
            $booking_long     = $record['booking_long'];
            $booking_lat      = $record['booking_lat'];
            $booking_date     = $record['booking_date'];
            $booking_time     = $record['booking_time'];
            $booking_total    = round(($booking_qty*$booking_price),2);
            $dtd              = $booking_date." ".$booking_time;
            $query_parts[]    = "('".$booking_date."','".$sdtd."','".$bid."','".$userid."','".$booking_invoice."','".$booking_custid."','".$booking_prodid."','".$booking_qty."','".$booking_bonus."','".$booking_price."','".$booking_total."','".$booking_discount."','".$booking_lat."','".$booking_long."','".$userid."','".$booking_time."')";
            $csvData         .= $booking_custid.",".$booking_prodid.",".$booking_qty.",".$booking_bonus.",".$booking_price.",".$booking_discount."\n";
          }
          $sql .= implode(',',$query_parts);
          if(mysqli_query($con, $sql)) {
            echo "Success";
          }else {
            echo mysqli_error($con);
          }

          // ** CSV FILE  ** //
          $myFile = "../appuploads/bookings/".$userid."-".strtotime(date("Y-m-d H:i:s")).".csv";
          $fo = fopen($myFile, 'w') or die("can't open file");
          fwrite($fo, $csvData);
          fclose($fo);
        }else {
          echo "No bookings found";
        }
      }else{
        echo "server can't acquire bookings";
      }
    }else{
      echo "Sorry, user is not authenticated";
    }
  }else{
    echo "server can't acquire userid of user";
  }
}else{
  echo "server can't acquire bid of user";
}
?>