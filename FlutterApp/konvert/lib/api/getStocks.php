<?php
@session_start();
if (!isset($con)) {
  include("appconfig.php");
}
if(isset($_POST['bid']) AND $_POST['bid'] != "") {
  $bid = $_POST['bid'];
  $dtd = date('Y-m-d');
  $sql= mysqli_query($con,"SELECT prod_id,name,branch_id,pack,grpid,batno,rate,expdtd,sum(qty) as qty,tp2,oldcode
  FROM (
   SELECT b.prod_id,b.name,b.branch_id,b.pack,b.grpid,a.batno,a.rate,a.exp_dtd as expdtd,(((a.pqty+a.pbns)-(a.rqty+a.rbns))-(a.scqty-a.rscqty)) as qty,b.tp2,b.oldcode from purchase a LEFT JOIN products b ON a.prod_id=b.prod_id WHERE a.BID='".$bid."' and a.dtd <='".$dtd."'
   UNION ALL
   SELECT b.prod_id,b.name,b.branch_id,b.pack,b.grpid,a.batno,a.rate,a.exp_dtd as expdtd,(((a.sqty+a.sbns)-(a.rfqty+a.rfbns))*-1) as qty,b.tp2,b.oldcode from sales a LEFT JOIN products b ON a.prod_id=b.prod_id WHERE a.BID='".$bid."' and a.dtd<='".$dtd."' && (a.rtype != 'E' && a.rtype != 'D')
   UNION ALL
   SELECT b.prod_id,b.name,b.branch_id,b.pack,b.grpid,a.batno,a.rate,a.expdtd as expdtd,a.qty as qty,b.tp2,b.oldcode from sadjustment a LEFT JOIN products b ON a.prod_id=b.prod_id WHERE a.BID='".$bid."' and a.dtd<='".$dtd."'
  ) as t1
  WHERE qty > 0
  GROUP BY prod_id
  ORDER BY prod_id") OR die(mysqli_error($con));
 
  $stocklist['stocklist'] = array();
  while($row = mysqli_fetch_assoc($sql)) {
    $stockrow = array();
    $stockrow["stock_id"]   = $row['prod_id'];
    $stockrow["stock_name"] = $row['name'];
    $stockrow["stock_qty"]  = $row['qty'];
    array_push($stocklist['stocklist'], $stockrow);
  }
  echo json_encode($stocklist);
}else{
  echo "server can't acquire BID of user";
}

?>