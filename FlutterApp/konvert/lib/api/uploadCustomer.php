<?php
@session_start();
include('appconfig.php');

if($_POST['userid']) 
{
  $bid    = $_POST['bid'];
  $userid = $_POST['userid'];
  $rw1 = mysqli_fetch_assoc(mysqli_query($con, "SELECT * FROM  profile WHERE BID='".$bid."' AND id='".$userid."' AND status = '' LIMIT 1"));

  if ($rw1) 
  {
    if($_POST['bid']) 
    {
      $dtd        = date('Y-m-d');
      $type       = $_POST["cust_type"];
      $category   = 70;
      $name       = $_POST["cust_name"];
      $brikid     = $_POST["cust_brikid"];
      $address    = $_POST["cust_address"];
      $city       = $_POST["cust_city"];
      $cperson    = $_POST["cust_cperson"];
      $phone      = $_POST["cust_phone"];
      $licno      = $_POST["cust_licno"];
      $lexdtd     = $_POST["cust_lexdtd"];
      $lcatg      = $_POST["cust_lcatg"];
      $ntnno      = $_POST["cust_ntnno"];
      $staxno     = $_POST["cust_staxno"];
      $lat        = $_POST["cust_long"];
      $long       = $_POST["cust_lat"];
      if ($_POST['SubmitCatgory']) {
        if ($_POST['SubmitCatgory'] == "AddCustomer") {
          $rwx = mysqli_fetch_assoc(mysqli_query($con, "SELECT * FROM brick WHERE BID='".$bid."' AND id='".$brikid."' LIMIT 1"));
          $sql = "INSERT IGNORE INTO profile(dtd,catgory,BID,subcat,acname,cityid,areaid,brikid,ad1,city,cperson,phone,licno,lexdtd,lcatg,ntnno,staxno,latit,longi)
          values ('".$dtd."','".$category."','".$bid."','".$type."','".$name."','".$rwx['cityid']."','".$rwx['areaid']."','".$brikid."','".$address."','".$city."','".$cperson."','".$phone."','".$licno."','".$lexdtd."','".$lcatg."','".$ntnno."','".$staxno."','".$lat."','".$long."')";
        }else if ($_POST['SubmitCatgory']=="UpdateCustomer") {
          $sid = $_POST['cust_id'];
          $sql = "UPDATE profile SET licno='".$licno."',lexdtd='".$lexdtd."',lcatg='".$lcatg."',ntnno='".$ntnno."',staxno='".$staxno."',latit='".$lat."',longi='".$long."' WHERE BID='".$bid."' AND id='".$sid."' AND latit ='' AND longi='' LIMIT 1";
        }
        $response = array();
        if(mysqli_query($con, $sql)) {
          $response['Success'] = "True";
          if ($_POST['SubmitCatgory'] == "AddCustomer") {
            $response['do']      = "AddNew";
            $response['CustID']  = mysqli_insert_id($con);
          }
        }else{
          $response['Success'] = "False";
        }
        echo json_encode(response);
      }else{
        echo "Object not found";
      }
    }else{
      echo "server can't acquire BID of user";
    }
  }else{
    echo "Sorry, user is not authenticated";
  }
}else{
  echo "server can't acquire userid of user";
}

?>