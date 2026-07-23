<?php
@session_start();
if (!isset($con)) {
  include('appconfig.php');
}
if($_POST['bid']) {
  $bid = $_POST['bid'];
  $rw1 = mysqli_fetch_assoc(mysqli_query($con, "SELECT * FROM profile WHERE BID='".$bid."' AND id='".$_POST['userid']."' LIMIT 1"));
  if ($rw1['vendid'] == '') {
    $sql = "SELECT distinct(prod_id),name,pack,branch_id,grpid,tp1,tp2,tp3,maxper,gst,staxper,is_otc,mrp,sch_g,oldcode
    FROM (
     SELECT a.prod_id,b.name,b.pack,b.branch_id,b.grpid,MAX(a.rate) AS tp1,b.tp2,b.tp3,b.maxper,b.gst,b.staxper,b.is_otc,b.mrp,b.sch_g,b.oldcode
      FROM purchase a LEFT JOIN products b ON a.prod_id=b.prod_id WHERE a.BID='".$bid."' AND b.stetus = '' GROUP BY a.prod_id ORDER BY a.id DESC
    ) AS t1
    ORDER BY name";
  }else{
    $sql = "SELECT distinct(prod_id),name,pack,branch_id,grpid,tp1,tp2,tp3,maxper,gst,staxper,is_otc,mrp,sch_g,oldcode
    FROM (
     SELECT a.prod_id,b.name,b.pack,b.branch_id,b.grpid,MAX(a.rate) AS tp1,b.tp2,b.tp3,b.maxper,b.gst,b.staxper,b.is_otc,b.mrp,b.sch_g,b.oldcode
      FROM purchase a LEFT JOIN products b ON a.prod_id=b.prod_id WHERE a.BID='".$bid."' AND b.stetus = '' AND b.branch_id='".$rw1['vendid']."' GROUP BY a.prod_id ORDER BY a.id DESC
    ) AS t1
    ORDER BY name";
  }
  $query = mysqli_query($con, $sql) or die(mysqli_error($con));
  $productlist['productlist'] = array();
  while($row = mysqli_fetch_assoc($query)) {
    $productrow = array();
    $productrow["prod_vendid"]   = $row['branch_id'];
    $productrow["prod_grpid"]    = $row['grpid'];
    $productrow["prod_id"]       = $row['prod_id'];
    $productrow["prod_name"]     = $row['name'].' '.$row['oldcode'];
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