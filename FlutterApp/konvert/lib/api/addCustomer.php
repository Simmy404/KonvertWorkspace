<?php
@session_start();
if (!isset($con)) {
    include('appconfig.php');
}

if ($_POST['bid']) {
    if ($_POST['userid']) {
        $dtd = date('Y-m-d');
        $json = json_decode($_POST['json_customer'], true);
        if ($json === null) {
            echo "invalid or malformed JSON";
            exit;
        }
        $response = array();
        try {
            $bid      = $_POST['bid'];
            $type     = $json["cust_type"];
            $category = 70;
            $name     = $json["cust_name"];
            $brikid   = $json["cust_brikid"];
            $address  = $json["cust_address"];
            $city     = $json["cust_city"];
            $cperson  = $json["cust_cperson"];
            $phone    = $json["cust_phone"];
            $licno    = $json["cust_licno"];
            $lexdtd   = $json["cust_lexdtd"];
            $lcatg    = $json["cust_lcatg"];
            $ntnno    = $json["cust_ntnno"];
            $staxno   = $json["cust_staxno"];
            $lat      = $json["cust_long"];
            $long     = $json["cust_lat"];

            $rwx = mysqli_fetch_assoc(mysqli_query($con, "SELECT * FROM brick WHERE BID='" . $bid . "' AND id='" . $brikid . "' LIMIT 1"));
            if ($rwx) {
                // Check if a customer already exists with same name and phone
                $checkSql = "SELECT id FROM profile WHERE acname='" . $name . "' AND phone='" . $phone . "' LIMIT 1";
                $checkResult = mysqli_query($con, $checkSql);

                if (mysqli_num_rows($checkResult) == 0) {
                    // Only insert if no duplicate found
                    $sql = "INSERT INTO profile(dtd,catgory,BID,subcat,acname,cityid,areaid,brikid,ad1,city,cperson,phone,licno,lexdtd,lcatg,ntnno,staxno,latit,longi)
                    VALUES ('" . $dtd . "','" . $category . "','" . $bid . "','" . $type . "','" . $name . "','" . $rwx['cityid'] . "','" . $rwx['areaid'] . "','" . $brikid . "','" . $address . "','" . $city . "','" . $cperson . "','" . $phone . "','" . $licno . "','" . $lexdtd . "','" . $lcatg . "','" . $ntnno . "','" . $staxno . "','" . $lat . "','" . $long . "')";
                    
                    if (mysqli_query($con, $sql)) {
                        $response['Success'] = "True";
                        $response['CustID'] = mysqli_insert_id($con);
                    } else {
                        $response['Success'] = "False";
                        $response['Error'] = "Insertion Failed";
                    }
                } else {
                    // Duplicate found: silently treat as success (ignore insertion)
                    $response['Success'] = "False";
                    $response['Error'] = "Customer already exist";
                }
            } else {
                $response['Success'] = "False";
                $response['Error'] = "Brick Not Found";
            }

            echo json_encode($response);
        } catch (Exception $e) {
            echo "missing or invalid field in json_customer";
            exit;
        }
    } else {
        echo "server can't acquire userid of user";
    }
} else {
    echo "server can't acquire BID of user";
}
?>
