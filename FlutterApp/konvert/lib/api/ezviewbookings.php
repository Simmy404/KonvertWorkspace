<?php
@session_start();
include('appconfig.php');
$event = array();
$dt1 = date('Y-m-d');
if (isset($_POST['userid']) && $_POST['userid'] != '') {
  $bid = $_POST['bid'];
  $userid = $_POST['userid'];
  if (isset($_POST['areaid']) && $_POST['areaid'] != '') {
    $areaid = " && b.brikid = '".intval($areaid)."' ";
  }else{
    $areaid = "";
  }
  $rw1 = mysqli_fetch_assoc(mysqli_query($con, "SELECT * FROM profile WHERE BID='".$bid."' AND id = '".$userid."' && status='' LIMIT 1"));
  if ($rw1['id'] != '') {
    $sql = mysqli_query($con,"SELECT a.purno,a.acno,sum(a.total) as total,b.acname,b.ad1,b.brikid as areaid FROM bookings a,profile b WHERE a.BID='".$rw1['BID']."' && a.UID='".$rw1['id']."' && a.dtd ='".$dt1."' && a.acno=b.id ".$areaid." GROUP BY a.purno,a.acno ORDER BY a.purno*1") or die(mysqli_error($con));
    $response["bookinglist"] = array();
    while ($row=  mysqli_fetch_assoc($sql)) {
      $events = array();
      $events["areaid"]   = $row['areaid'];     // order area id
      $events["purno"]    = $row['purno'];      // order number
      $events["cust_id"]  = $row['acno'];       // customer id
      $events["cust_name"]= $row['acname'];     // customer name
      $events["cust_addr"]= $row['ad1'];        // customer address
      $events["total"]    = $row['total'];      // total amount
      array_push($response["bookinglist"],$events);
    }
    echo json_encode($response);
  }else{
    $event['Success'] = "Invalid Username || Password";
    echo json_encode($event);
  }
}else{
  $event['Error'] = "Username not found";
  echo json_encode($event);
}
?>