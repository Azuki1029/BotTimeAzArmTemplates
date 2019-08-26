Param
(
    [Parameter(Mandatory=$true)]
    [String] $Endpoint

	[Parameter(Mandatory=$true)]
	[String] $License
)

$apiEndpoint = "http://${Endpoint}:8080";
$imageEndpoint = "http://${Endpoint}:8081";

systemctl start mysqld

if (-not [string]::IsNullOrEmpty($License))
{
	Start-Sleep -Seconds 10
	"update consoledb.sys_config set config_value = '${License}' where config_id = 125;" | out-File /encoo/setLicense.sql -Force
	mysql -h localhost -u consoleuser -p'Encoo123!@#' -e 'source /encoo/setLicense.sql'
}

systemctl start redis

"nohup java -jar /encoo/imageServer.jar --port=8081 --host=${imageEndpoint} --path=/encoo/fileserver &" | Out-File /encoo/startImageServer.sh -Force
sh /encoo/startImageServer.sh

sh /encoo/start.sh start

(gci /encoo/frontend/index*js | gc).Replace("AP1P1ACEHOLDER", $apiEndpoint) | Out-File (gci /encoo/frontend/index*js).FullName -Force
systemctl start nginx