<?php
include('lib/database.inc.php');
pageheader("Main Page");
$usersa =  array();
$sql = "SELECT `id` FROM `$db`.`wifi0`";
$result0 = mysql_query($sql, $conn);
$rows = mysql_num_rows($result0);

$sql = "SELECT `id` FROM `$db`.`$wtable` WHERE `sectype`='1'";
$result1 = mysql_query($sql, $conn);

$sql = "SELECT `id` FROM `$db`.`$wtable` WHERE `sectype`='2'";
$result2 = mysql_query($sql, $conn);

$sql = "SELECT `id` FROM `$db`.`$wtable` WHERE `sectype`='3'";
$result3 = mysql_query($sql, $conn);

$sql = "SELECT `id`,`ssid` FROM `$db`.`$wtable` ORDER BY ID DESC LIMIT 1";
$result4 = mysql_query($sql, $conn);

$sql = "SELECT `username` FROM `$db`.`$users_t`";
$result5 = mysql_query($sql, $conn);

#
$row_users = mysql_num_rows($result5);
while($user_array = mysql_fetch_array($result5))
{
	$usersa[]=$user_array['username'];
}
$usersa = array_unique($usersa);
$usercount = count($usersa);
if ($usercount == NULL)
{
	$lastuser['username'] = "No imports have finished yet.";
	$lastuser['title'] = "No imports have finished yet.";
	$lastuser['date'] = date("Y-m-d H:i:s");
}
if ($usercount == NULL){}

$sql = "SELECT username, title, id, date FROM `$db`.`$users_t` WHERE `id`='$row_users'";
$result6 = mysql_query($sql, $conn);
#
$open = mysql_num_rows($result1);
#
$WEP = mysql_num_rows($result2);
#
$Sec = mysql_num_rows($result3);
#
$lastap_array = mysql_fetch_array($result4);
$lastap_id = $lastap_array['id'];
$lastap_ssid = $lastap_array['ssid'];
#
$lastuser = mysql_fetch_array($result6);
if(!$result0 OR !$result1 OR !$result2 OR !$result3 OR !$result4 OR !$result5 or !$result6)
{
	echo "<br /><p><h2>There is a serious error trying to get data from the Database, check it out.<br />You may need to reinstall.</h2></p>";
	footer($_SERVER['SCRIPT_FILENAME']);
	die();
}
?>
			To View all AP's click <a class="links" href="all.php?sort=SSID&ord=ASC&from=0&to=100">Here</a><br><br>
<table WIDTH=85% BORDER=1 CELLPADDING=2 CELLSPACING=0>
	<tr>
		<td colspan="4" class="style1"><strong><em>Statistics</em></strong></td>
	</tr>
	<tr class="style3"><td class="style2" colspan="4" ></td></tr>
	<tr>
		<th class="style3" style="width: 100px">Total AP&#39;s</th>
		<th class="style3">Open AP&#39;s</th>
		<th class="style3">WEP AP&#39;s</th>
		<th class="style3">Secure AP&#39;s</th>
	</tr>
	<tr class="light">
		<td align="center" class="style2" style="width: 100px"><?php echo $rows; ?></td>
		<td align="center" class="style2"><?php echo $open; ?></td>
		<td align="center" class="style2"><?php echo $WEP; ?></td>
		<td align="center" class="style2"><?php echo $Sec; ?></td>
	</tr>
	<tr class="style3"><td class="style2" colspan="4" ></td></tr>
	<tr>
		<th class="style3" style="width: 100px">Total Users</th>
		<th class="style3">Last user to import</th>
		<th class="style3">Last AP added</th>
		<th class="style3">Last Import List</th>
	</tr>
	<tr class="dark">
		<td align="center" class="style2" style="width: 100px"><?php echo $usercount;?></td>
		<td align="center" class="style2"><?php if ($usercount == NULL){echo "No users in Database.";}else{?><a class="links" href="opt/userstats.php?func=alluserlists&user=<?php echo $lastuser['username'];?>"><?php echo $lastuser['username'];?></a><?php } ?></a></td>
		<td align="center" class="style2"><?php if($lastap_ssid==''){echo "No APs imported yet.";}else{?><a class="links" href="opt/fetch.php?id=<?php echo $lastap_id;?>"><?php echo $lastap_ssid;?></a><?php } ?></td>
		<td align="center" class="style2"><?php if($lastap_ssid==''){echo "No imports yet.";}else{?><a class="links" href="opt/userstats.php?func=useraplist&row=<?php echo $lastuser['id'];?>"><?php echo $lastuser['title'];?></a><br> [ <?php echo $lastuser['date']."]"; } ?> </td>
	</tr>
</table>
<table width="75%"><td><tr>
<?php
if ($_SERVER['HTTP_HOST'] == "rihq.randomintervals.com" or $_SERVER['HTTP_HOST'] == "www.randomintervals.com" or $_SERVER['HTTP_HOST'] == "192.168.1.26" or $_SERVER['HTTP_HOST'] == "randomintervals.com")
{echo '<b><font size="3">This is one of my Development servers </font><br>
<font size="2">(which is unstable because I am always working in it)</font><br>
<font size="3">Go on over to the <i>Vistumbler <a class="links" target="_blank" href="http://www.vistumbler.net/wifidb/">\'Production Server\'</i></a> for a more stable environment</font></b>';}
?>
</td></tr></table>
<?php
footer($_SERVER['SCRIPT_FILENAME']);
?>