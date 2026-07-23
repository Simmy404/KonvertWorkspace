<?php
@session_start();
if (!isset($con)) {
  include('appconfig.php');
}
if(isset($_POST['username']) && isset($_POST['password'])) {
  $username = $_POST['username'];
  $password = $_POST['password'];
  $apiKey   = $_POST['apiKey'];
  $orderDistance = 200; // meters
  $orderInterval = 2; // minutes
  $rw1 = mysqli_fetch_assoc(mysqli_query($con, "SELECT * FROM branch WHERE branch_id='".$apiKey."' and hawkeye_auth = 'Active' LIMIT 1"));
  if ($rw1) { 
    $sql = "SELECT * FROM profile WHERE BID='".$apiKey."' AND login = '".$username."' AND pword = '".$password."' AND status = '' LIMIT 1";
    $row1 = mysqli_fetch_assoc(mysqli_query($con, $sql));
    if($row1) {
      $userdata = array();
      $userdata['id'] = $row1['id'];
      $userdata['name'] = $row1['acname'];
      $userdata['bid'] = $row1['BID'];
      $userdata['category'] = $row1['catgory'];
      $userdata['orderDistance'] = $orderDistance;
      $userdata['orderInterval'] = $orderInterval;
      if ($rw1['hawkeye_type'] == "online") {
        $userdata['isOnline'] = "online";
      }else{
        $userdata['isOnline'] = "offline";
      }
      $userdata['GoogleAPI'] = $rw1['google_api'];
      echo json_encode($userdata);
    }else{
      echo "incorrect username or password";
    }
  }else{
    echo "Authorization Failed!";
  }
}else{
  echo "server cannot acquire username or password";
}
?>
