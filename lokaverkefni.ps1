#Grunn OU og Group
New-ADOrganizationalUnit -Name Notendur -ProtectedFromAccidentalDeletion $false
$grunnOUPath = (Get-ADOrganizationalUnit -Filter { name -like 'Notendur' }).DistinguishedName
New-ADOrganizationalUnit -Name Upplýsingatækniskólinn -Path $grunnOUPath -ProtectedFromAccidentalDeletion $false
$skolapath = (Get-ADOrganizationalUnit -Filter { name -like 'Upplýsingatækniskólinn' }).DistinguishedName
New-ADOrganizationalUnit -Name Kennarar -Path $skolapath -ProtectedFromAccidentalDeletion $false
New-ADOrganizationalUnit -Name Nemendur -Path $skolapath -ProtectedFromAccidentalDeletion $false
New-ADGroup -Name NotendurGRP -Path $grunnOUPath -GroupScope Global
#Paths
$nemendurPath = (Get-ADOrganizationalUnit -Filter { name -like 'Nemendur' }).DistinguishedName
$kennaraPath = (Get-ADOrganizationalUnit -Filter { name -like 'Kennarar' }).DistinguishedName
#Nemanda Groups
New-ADGroup -Name NemendurGRP -Path $NemendurPath -GroupScope Global
#Kennara Groups
New-ADGroup -Name KennaraGRP -Path $kennaraPath -GroupScope Global

$TolvuOU = "OU=Tölvubraut,OU=Nemendur,OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local"
$kennaraOU = "OU=TölvubrautK,OU=Kennarar,OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local"
$notendur = Import-Csv .\notendur.csv
$x = 0
foreach($n in $notendur){ 
    $braut = $n.Braut
    $brautk = $braut + 'K'
    $hlutverk = $n.Hlutverk   
 if($n.hlutverk -eq 'Nemendur'){
    if(-not(Get-ADOrganizationalUnit -SearchBase "OU=Nemendur,OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local" -Filter { name -like $braut })){
    New-ADOrganizationalUnit -name $braut -Path 'OU=Nemendur,OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local' -ProtectedFromAccidentalDeletion $false  
    }    
    $x = $x+=1    
    $notendanafn = $n.nafn
    $givenname = $notendanafn.split('') | Select-Object -First 1
    $surname = $notendanafn.split('') | Select-Object -Last 1
    $notendanafn = $notendanafn -replace "Þ|þ" , "th" -replace "Æ|æ" , "ae" -replace "ð" , "d" -replace "Ö|ö" , "o" -replace "Í|í" , "i" -replace "Á|á","a" -replace "É|é","e" -replace "Ó|ó","o" -replace "Ú|ú","u" -replace "Ý,ý","y";
    $fornafn = $notendanafn.split('') | Select-Object -First 1
    $eftirnafn = $notendanafn.split('') | Select-Object -Last 1
       
    $notendanafn = $fornafn.Substring(0,2) + $eftirnafn.Substring(0,2) + $x
    $notendanafn = $notendanafn.ToLower()   
    if(-not(Get-ADGroup -SearchBase "OU=$braut,OU=Nemendur,OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local" -Filter { name -like $braut })){
    New-ADGroup -Name $braut -Path "OU=$braut,OU=Nemendur,OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local" -GroupScope Global
    }
    }
 elseif($n.hlutverk -eq 'Kennarar'){ 

    if(-not(Get-ADOrganizationalUnit -SearchBase "OU=Kennarar,OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local" -Filter { name -like $brautk })){
    New-ADOrganizationalUnit -name $brautk -Path 'OU=Kennarar,OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local' -ProtectedFromAccidentalDeletion $false
    }    
    $notendanafn = $n.nafn
    $notendanafn = $notendanafn -replace "Þ|þ" , "th" -replace "Æ|æ" , "ae" -replace "ð" , "d" -replace "Ö|ö" , "o" -replace "Í|í" , "i" -replace "Á|á","a" -replace "É|é","e" -replace "Ó|ó","o" -replace "Ú|ú","u" -replace "Ý,ý","y";
    $fornafn = $notendanafn.split('') | Select-Object -First 1
    $eftirnafn = $notendanafn.split('') | Select-Object -Last 1    
    $notendanafn = $fornafn +"."+ $eftirnafn      
    if ($notendanafn.length -gt 20){
        $notendanafn = $notendanafn.Substring(0,20)
    }
    $notendanafn = $notendanafn.ToLower()
    
    if(-not(Get-ADGroup -SearchBase "OU=$brautk,OU=Kennarar,OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local" -Filter { name -like $brautk })){
    New-ADGroup -Name $brautk -Path "OU=$brautk,OU=Kennarar,OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local" -GroupScope Global
    }
 }
    $notandi = @{
    'Name' = $n.nafn;
    'DisplayName' = $n.nafn;
    'SamAccountName' = $notendanafn;
    'GivenName' = $givenname;
    'Surname' = $surname;
    'Title' = $n.hlutverk;
    'Department' = $n.braut;
    'AccountPassword' = (ConvertTo-SecureString -AsPlainText "pass.123" -Force);
    'Enabled' = $true;
    'UserPrincipalName' = $($notendanafn + "@" + $env:USERDNSDOMAIN);
    'Path' = if($n.hlutverk -eq 'Nemendur'){$("OU=" + $braut + "," + 'OU=' + $n.Hlutverk +  ',OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local')}elseif($n.hlutverk -eq 'Kennarar'){$("OU=" + $brautk + "," + 'OU=' + $n.Hlutverk +  ',OU=Upplýsingatækniskólinn,OU=Notendur,DC=eep-hilmar,DC=local')};
    } 
    New-ADUser @notandi;
    Add-ADGroupMember -Identity 'NotendurGRP' -Members $notendanafn
    if($n.hlutverk -eq 'Nemendur'){
    Add-ADGroupMember -Identity $braut -Members $notendanafn
    Add-ADGroupMember -Identity 'NemendurGRP' -Members $notendanafn  
    }
    elseif($n.Hlutverk -eq 'Kennarar'){    
    Add-ADGroupMember -Identity $brautk -Members $notendanafn
    Add-ADGroupMember -Identity 'KennaraGRP' -Members $notendanafn    
    }
    else{
    "Villa Villa Villa Villa"
    }    
}





### DNS ###

# Búa til lénið skoli.is, þarf bara að gera einu sinni.
Add-DnsServerPrimaryZone -Name "tskoli.is" -ReplicationScope Domain

# Búa til host færslu fyrir www (IPv4)
# Add-DnsServerResourceRecordA -ZoneName "tskoli.is" -Name "www" -IPv4Address "*"
# Hér mætti svo bæta við fleiri host færslum fyrir t.d. skoli.is (án www)
$vefsiduN = $TolvuOU | ForEach{Get-AdUser -filter * -SearchBase $_}

foreach($n in $vefsiduN.SamAccountName){
    


### IIS ###

# Setja inn IIS role-ið, þarf bara að gera einu sinni.
#Install-WindowsFeature web-server -IncludeManagementTools

# Búa til nýja möppu í wwwroot
New-Item "C:\inetpub\wwwroot\$n.tskoli.is" -ItemType Directory
$rettindi = Get-Acl -Path "C:\inetpub\wwwroot\$n.tskoli.is"
        $nyrettindi = New-Object System.Security.AccessControl.FileSystemAccessRule($($env:USERDOMAIN + "\" + "$n"),"FullControl","Allow")
        $rettindi.AddAccessRule($nyrettindi)
        Set-Acl -Path "C:\inetpub\wwwroot\$n.tskoli.is" $rettindi
        New-SmbShare -Name "$n.tskoli.is" -Path "C:\inetpub\wwwroot\$n.tskoli.is" -FullAccess $env:USERDOMAIN\$n, administrators

# Búa til html skjal sem inniheldur "Vefsíðan www.skoli.is" í nýju möppuna
New-Item "C:\inetpub\wwwroot\$n.tskoli.is\index.html" -ItemType File -Value "Vefsíðan $n"

# Búa til nýja vefsíðu á vefþjóninn
New-Website -Name "www.$n.tskoli.is" -HostHeader "www.$n.tskoli.is" -PhysicalPath "C:\inetpub\wwwroot\$n.tskoli.is\"
# Ef það þarf að bæta við fleiri hostheader-um má gera það
New-WebBinding -Name "www.$n.tskoli.is" -HostHeader "$n.tskoli.is"
   
   Invoke-Sqlcmd -Query "use master
                     GO
                     create database $n
                     create login [eep-hilmar\$n] from Windows
                     GO
                     USE $n
                     GO
                     EXEC sp_changedbowner $n;
                     "   
}
$sqlK = $kennaraOU | ForEach{Get-AdUser -filter * -SearchBase $_}
foreach($n in $sqlK.SamAccountName){
   Invoke-Sqlcmd -Query "use master
                     GO
                     create database $n
                     create login [eep-hilmar\$n] from Windows
                     GO
                     USE $n
                     GO
                     EXEC sp_changedbowner $n;
                     " 

}

                     