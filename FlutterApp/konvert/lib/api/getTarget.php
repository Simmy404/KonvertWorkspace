<?php
@session_start();
include('appconfig.php');

/* *** FOR MAIN ACTIVITY *** */
$_POST['dt1']    = date('Y-m-01');
$_POST['dt2']    = date('Y-m-d');
$event = array();

// $_POST['bid'] = '28';
// $_POST['userid'] = '10532';

if (isset($_POST['userid']) && $_POST['userid'] != '') {
  $bid = $_POST['bid'];
  $userid = $_POST['userid'];

  if (isset($_POST['dt1']) && $_POST['dt1'] == '') 
  {
    $dt1 = $_POST['dt1'];
  }else{
    $dt1 = date('Y-m-01');
  }

  if (isset($_POST['dt2']) && $_POST['dt2'] == '') 
  {
    $dt2 = $_POST['dt2'];
  }else{
    $dt2 = date('Y-m-d');
  }

  $rw1 = mysqli_fetch_assoc(mysqli_query($con, "SELECT * FROM profile WHERE BID='".$bid."' AND id = '".$userid."' AND status = '' LIMIT 1"));

  if ($rw1['id'] != '') 
  {

    $sql = mysqli_query($con,"SELECT sum(tdsales)  as tdsales,sum(tsales) as tsales, sum(norders) as norders,sum(target) as target
    FROM (
     SELECT if(dtd = '".$dt2."',(total-rtotal),0) AS tdsales,(total-rtotal) AS tsales,0 AS norders,0 AS target FROM sales WHERE BID='".$rw1['BID']."' && (dtd >='".$dt1."' && dtd<='".$dt2."') && bkby='".$rw1['id']."'
     UNION ALL
     SELECT 0 AS tdsales,0 AS tsales,count(distinct(acno)) AS norders,0 AS target FROM sales WHERE BID='".$rw1['BID']."' && dtd = '".$dt2."' && bkby='".$rw1['id']."'
    ) AS t1") OR die(mysqli_error($con));
    $response["targetlist"] = array();

    while ($row=  mysqli_fetch_assoc($sql)) 
    {
      $events = array();
      $events["month_target"] = $row['target'];    // TARGET
      $events["total_sales"]  = $row['tsales'];    // TOTAL SALES
      $events["today_sales"]  = $row['tdsales'];   // TODAY SALES
      $events["no_of_orders"] = $row['norders'];   // NO OF ORDERS
      array_push($response["targetlist"],$events);

    }
    echo json_encode($response);
  }else{
    echo "Invalid Username || Password";
  }
}else{
  echo "Username not found";
}

?>