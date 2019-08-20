Param
(
    [Parameter(Mandatory=$true)]
    [String] $Endpoint
)

$apiEndpoint = "http://${Endpoint}:8080";
$imageEndpoint = "http://${Endpoint}:8081";

systemctl start mysqld
systemctl start redis

"nohup java -jar /encoo/imageServer.jar --port=8081 --host=${imageEndpoint} --path=/encoo/fileserver &" | Out-File /encoo/startImageServer.sh -Force
sh /encoo/startImageServer.sh

sh /encoo/start.sh start

(gci /encoo/frontend/index*js | gc).Replace("AP1P1ACEHOLDER", $apiEndpoint) | Out-File (gci /encoo/frontend/index*js).FullName -Force
systemctl start nginx