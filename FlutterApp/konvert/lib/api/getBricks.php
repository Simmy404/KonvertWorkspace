<?php

include('appconfig.php');

if($_POST['bid'])
{

    $bid = $_POST['bid'];

    $sql = "SELECT * FROM brick where BID = '".$bid."' ORDER BY acname";
    $query = mysqli_query($con, $sql);
    $bricklist['bricklist'] = array();
    
    while($row = mysqli_fetch_assoc($query))
    {
        $brickrow = array();
        $brickrow['brik_id']    = $row['id'];
        $brickrow['brik_name']  = $row['acname'];

        array_push($bricklist['bricklist'], $brickrow);
    }

    echo json_encode($bricklist);

}else{
    echo "server can't acquire BID of user";
}


?>