<?php
@session_start();
include('appconfig.php');

if($_POST['bid']) 
{
    $bid = $_POST['bid'];
    $sql = "SELECT * FROM profile WHERE BID = '".$bid."' AND catgory = '70' AND status = '' ORDER BY acname";
    $query = mysqli_query($con, $sql);
    $customerlist['customerlist'] = array();

    while($row = mysqli_fetch_assoc($query)) 
    {
        $customerrow = array();
        $customerrow["cust_id"]      = $row['id'];
        $customerrow["cust_type"]    = $row['subcat'];
        $customerrow["cust_name"]    = $row['acname'].' '.$row['vendid'];
        $customerrow["cust_brikid"]  = $row['brikid'];
        $customerrow["cust_address"] = $row['ad1'];
        $customerrow["cust_city"]    = $row['cityid'];
        $customerrow["cust_cperson"] = $row['cperson'];
        $customerrow["cust_phone"]   = $row['phone'];
        $customerrow["cust_licno"]   = $row['licno'];
        $customerrow["cust_lexdtd"]  = $row['lexdtd'];
        $customerrow["cust_lcatg"]   = $row['lcatg'];
        $customerrow["cust_ntnno"]   = $row['ntnno'];
        $customerrow["cust_staxno"]  = $row['staxno'];
        $customerrow["cust_lat"]     = $row['longi'];
        $customerrow["cust_long"]    = $row['latit'];
        
        array_push($customerlist['customerlist'], $customerrow);
    }
    echo json_encode($customerlist);
}else
{
    echo "server can't acquire BID of user";
}
?>