<?php
@session_start();
include('appconfig.php');

if($_POST['bid']) {
  $bid = $_POST['bid'];
  $sql = "SELECT * FROM products where BID = '".$bid."' AND stetus='' ORDER BY name";
  $query = mysqli_query($con, $sql);
  $productlist['productlist'] = array();
  while($row = mysqli_fetch_assoc($query)) {
    $productrow = array();
    $productrow["prod_vendid"]   = $row['branch_id'];
    $productrow["prod_grpid"]    = $row['grpid'];
    $productrow["prod_id"]       = $row['prod_id'];
    $productrow["prod_name"]     = $row['name'];
    $productrow["prod_packsize"] = $row['pack'];
    $productrow["prod_maxper"]   = $row['maxper'];
    $productrow["prod_gstper"]   = $row['gst'];
    $productrow["prod_staxper"]  = $row['staxper'];
    $productrow["prod_is_otc"]   = $row['is_otc'];
    $productrow["prod_is_sch_g"] = $row['sch_g'];
    $productrow["prod_retail"]   = $row['mrp'];
    if ($row['tp2'] == 0) {
      $productrow["prod_tp"]= $row['tp1'];
    }else{
      if ($row['tp3'] != 0) {
        $productrow["prod_tp"]= $row['tp3'];
      }else {
        $productrow["prod_tp"]= $row['tp2'];
      }
    }
    array_push($productlist['productlist'], $productrow);
  }
  echo json_encode($productlist);
}else{
  echo "server can't acquire BID of user";
}
?>