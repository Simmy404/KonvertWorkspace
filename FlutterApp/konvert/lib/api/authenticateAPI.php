<?php
@session_start();
if (!isset($con)) {
  include('appconfig.php');
}
$apiKey = $_POST['apiKey'];
$domainURL = $_POST['domain'];
$rw1 = mysqli_fetch_assoc(mysqli_query($con, "SELECT * FROM branch WHERE branch_id='".$apiKey."' and hawkeye_auth = 'Active' LIMIT 1"));
if ($rw1) { 
  echo "success";
}else{
  echo "Authorization Failed!";
}
?>