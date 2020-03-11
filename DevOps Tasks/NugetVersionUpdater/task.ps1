
# For more information on the Azure DevOps Task SDK:
# https://github.com/Microsoft/vsts-task-lib
Trace-VstsEnteringInvocation $MyInvocation
try {
    
    $packageName = Get-VstsInput -Name 'packageName' -Require
    $maxIncrement = Get-VstsInput -Name 'maxIncrement' -Require
    $pipelineVariable = Get-VstsInput -Name 'pipelineVariable' -Require

    Write-Host "The Package in use is: " $packageName
    Write-Host "The Max Increment version is: " $maxIncrement
    
    #Add Package Source
    Write-Host "Adding Nuget Package Source"
    Register-PackageSource -Name NuGet -Location https://www.nuget.org/api/v2 -ProviderName NuGet
    
    #Get the current version for the Package
    $currentVersion = "1.0.0";

    if(Find-Package $packageName -Source NuGet -ErrorAction SilentlyContinue){
        #If the package does exist, set the current Version variable
        $currentVersion = Find-Package $packageName -Source NuGet | Select-Object -ExpandProperty Version
        
    }
    else{
        Write-Host "Package $packageName Does not exists. New package will be pushed"
    }

    #Split version
    $Major = $currentVersion.Split(".")[0] -as [int]
    $Minor = $currentVersion.Split(".")[1] -as [int]
    $Patch = $currentVersion.Split(".")[2] -as [int]

    #Set new/next version of Package
    $newVersion;
    
    if(($Patch + 1) -eq $maxIncrement) {

        #Increment the Minor version and reset patch version to 0
        Write-Host "Patch version value has been reached the Max Increment value supplied."
        Write-Host "Reset the Patch version to 0 and Increment the Minor version by 1"

        $Minor = ($Minor = + 1);
        $Patch = 0;
     }else {
        
        #Increment the Patch version
        Write-Host "Patch version value has not been reached the Max Increment value supplied. Only Increment Patch version."

        $Patch = ($Patch + 1);
     }

    $newVersion = ($Major, $Minor, $Patch) -Join "."
    
    # Output the message to the log.
    Write-Host "Old Version of Package: " $currentVersion
    Write-Host "New Version for Package: " $newVersion
    
    Write-Host "Set environment variable to ($newVersion)"

    # Output the new version to be used by the subsequent tasks
    Write-Output "##vso[task.setvariable variable=$pipelineVariable;]$newVersion"
    
    Write-Host "New Package version $newVersion"
    
} finally {
    Trace-VstsLeavingInvocation $MyInvocation
}
