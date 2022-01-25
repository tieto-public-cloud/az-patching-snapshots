# Login your powershell session to Elo environment via connect-azaccount command and then execute this script.
# When executing the script provide name of the patching group tag value to parameters:
# SubscriptionId: this is Id of subscription where patched VMs reside
# SnapResGroupName: Name of resource group used to store the snapshots
# UpdateGroupName: Name of the patching group (value for tag te-updmgmt-group on patched VM)
#
# it will automatically create OS disk snapshots from all VMs in subscription that have tag "te-updmgmt-group" value specified

# Example execution
# ./Azure-CreateSnapshots.ps1 -SubscriptionId "3a60e7b7-ac49-45d8-8a8f-ba61cdc5dc1f" -SnapResGroupName "rg-teshared-custz-test" -UpdateGroupName "group-prod-1"

param ($SubscriptionId, $SnapResGroupName, $UpdateGroupName)


function createSnapshot {
    param ($VmName, $Location, $VmResGroupName) 
    $VM = Get-AzVM -ResourceGroupName $VmResGroupName -Name $VmName
    $OsDisk = $VM.StorageProfile.OsDisk
    $Timestamp = Get-Date -Format "yyyyMMddHHmm"

    $Snapshot =  New-AzSnapshotConfig -SourceUri $OsDisk.ManagedDisk.Id -Location $Location -CreateOption copy -Tag @{"source-disk-resource-group"=$VmResGroupName; "source-disk-id"=$OsDisk.ManagedDisk.Id; "source-disk-name"=$OsDisk.Name}
    $SnapshotName = "snapOsDisk-" + $(if ($VmName.length -gt 55) { $VmName.substring(0, 55) } else { $VmName }) + "-" + $Timestamp
    write-host "Creating snapshot: $SnapshotName"
    New-AzSnapshot -Snapshot $Snapshot -SnapshotName $SnapshotName -ResourceGroupName $SnapResGroupName
}

Set-AzContext -Subscription $SubscriptionId

foreach ($V in $(Get-AzResource -ResourceType "Microsoft.Compute/virtualMachines" -TagName "te-updmgmt-group" -TagValue $UpdateGroupName)) {
    createSnapshot -VmName $V.name -Location $V.location -VmResGroupName $V.ResourceGroupName
}
