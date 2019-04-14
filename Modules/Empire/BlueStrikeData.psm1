#### All functions need to have proper function params, synopsis, help, etc....
#### Also where my psd1 file at

$EmpireConfigFilePath = 'Data\EmpireConfig.json'
$EmpireModuleFilePath = 'Data\EmpireModules.json'
$EmpireAgentFilePath = 'Data\EmpireAgents.json'
$NetworkScanFilePath = 'Data\NetworkScan.json'
$BSLogFilePath = 'Data\AuditLog.log'


Function Get-BSJSONObject 
{
Param(
    $BSFile = ''
)

    if(Test-Path($BSFile))
    {
        $FileContents = Get-Childitem -file $BSFile  
        $Length = $FileContents.Length

        iF($Length -ne 0)
        {
            $JsonObject = ConvertFrom-Json -InputObject (Get-Content $BSFile -raw)
            return $JsonObject
        }
        else 
        {
            # Empty File
            return $null
        }

        
    }
    else 
    {
        # Does not Exist
        return $null
    }
}

Function Get-BSEmpireAgentData()
{

    $Data = @()
    $ResourcesJsonContent = Get-BSJSONObject -BSFile $EmpireAgentFilePath

    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
        $Data = $Data +[PSCustomObject]@{
            id=($Resource.id);
            name=($Resource.name);
            checkin_time=($Resource.checkin_time);
            external_ip=($Resource.external_ip);
            hostname=($Resource.hostname);
            internal_ip=($Resource.internal_ip);
            langauge=($Resource.langauge);
            langauge_version=($Resource.langauge_version);
            lastseen_time=($Resource.lastseen_time);
            listener=($Resource.listener);
            os_details=($Resource.os_details);
            username=($Resource.username);
        }
    }
    
    return $Data
}



Function Get-BSEmpireConfigData()
{

    $Data = @()
    $ResourcesJsonContent = Get-BSJSONObject -BSFile $EmpireConfigFilePath

    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
        $Data = $Data +[PSCustomObject]@{
            empire_host=($Resource.empire_host);
            empire_port=($Resource.empire_port);
            empire_token=($Resource.empire_token);
            api_username=($Resource.api_username);
            install_path=($Resource.install_path);
            version=($Resource.version);
            sync_time=($Resource.sync_time)
        }
    }

    return $Data


}


Function Get-BSEmpireModuleData()
{
    
    $Data = @()
    $Options = @()
    $FirstPartOfDefinition = '^.*=@{Description='
    $SecondPartOfDefinition = ';.*;.*Value=.*}'

    $ResourcesJsonContent = Get-BSJSONObject -BSFile $EmpireModuleFilePath

    #### Data Stuff
    foreach($Module in $ResourcesJsonContent)
    {

        #Propertize the Module Objects
        $ModuleOptionsObject = @()
        $ModuleOptions = $Module.options 
        
        $ModuleOptionsNotes = $ModuleOptions | Get-Member -MemberType NoteProperty
        ForEach($Note in $ModuleOptionsNotes)
        {

            $OptionDefinitionFormatted = $Note.Definition
            $OptionDefinitionFormatted = $OptionDefinitionFormatted -replace $FirstPartOfDefinition," "
            $OptionDefinitionFormatted = $OptionDefinitionFormatted -replace $SecondPartOfDefinition,""

            $ModuleOptionsObject = $ModuleOptionsObject +[PSCustomObject]@{
                Name=($Note.Name);
                Definition=($OptionDefinitionFormatted);
            }
        }


        $Data = $Data +[PSCustomObject]@{
            Name=($Module.name);
            Author=($Module.Author);
            Description=($Module.Description);
            Language=($Module.Language);
            NeedsAdmin=($Module.NeedsAdmin);
            OpsecSafe=($Module.OpsecSafe);
            Options=($ModuleOptionsObject);
        }
    }



    return $Data


}


Function Get-BSNetworkScanData()
{

    $Data = @()
    $ResourcesJsonContent = Get-BSJSONObject -BSFile $NetworkScanFilePath
        
    #### Data Stuff
    foreach($Resource in $ResourcesJsonContent)
    {
        $Data = $Data +[PSCustomObject]@{
            HostName=($Resource.Hostname);
            IPv4=($Resource.IPv4);
            Status=($Resource.Status);
            Computer=(New-UDLink -Text "RDP" -Url "remotedesktop://$Resource.IPv4");
            Note="";
            LastScan=($Resource.ScanTime.DateTime);
            isEmpire=($Resource.EmpireServer);
        }
    }
       
    return $Data

}



Function Clear-BSJON
{
Param(
    $BSFile = ''
)
    if(Test-Path($BSFile))
    {
         # Clear Existings
        Clear-Content $BSFile -Force
    }
    else 
    {
        # Does not Exist
    }
}


Function Write-BSJSON
{
Param (
    [Parameter(Mandatory=$true)] $BSFile = '',
    [Parameter(Mandatory=$true)] $BSObjectData
)

$BSObjectData | ConvertTo-Json | Out-File $BSFile -Append


}


Function Write-BSObjectToJSON
{
Param (
    [Parameter(Mandatory=$true)] $BSFile = '',
    [Parameter(Mandatory=$true)] $BSObjectData
)

$BSObjectData | ConvertTo-Json | Out-File $BSFile -Append


}




Function Write-BSEmpireAgentData
{
Param (
    $BSObjectData        
)

    Clear-BSJON -BSFile $EmpireAgentFilePath
    Write-BSJSON -BSFile $EmpireAgentFilePath -BSObjectData $BSObjectData


}


Function Write-BSEmpireConfigData
{
Param (
    $BSObjectData        
)
    Clear-BSJON -BSFile $EmpireConfigFilePath
    Write-BSJSON -BSFile $EmpireConfigFilePath -BSObjectData $BSObjectData


}

Function Write-BSEmpireModuleData
{
Param (
    $BSObjectData        
)
    Clear-BSJON -BSFile $EmpireModuleFilePath
    Write-BSJSON -BSFile $EmpireModuleFilePath -BSObjectData $BSObjectData
    

}



Function Write-BSNetworkScanData
{
Param (
    $BSObjectData        
)
    Clear-BSJON -BSFile $NetworkScanFilePath
    Write-BSJSON -BSFile $NetworkScanFilePath -BSObjectData $BSObjectData
    
}

Function Write-BSAuditLog
{
Param (
    $BSLogContent
)
    $BSLogContentFormatted = ($(Get-Date -Format 'yyyy-MM-dd hh:mm:ss') + ' : ' + $BSLogContent)
    $BSLogContentFormatted | Out-File $BSLogFilePath -Append
}