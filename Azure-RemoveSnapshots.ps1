# Example execution
# ./Azure-RemoveSnapshots.ps1 -SubscriptionId "3a60e7b7-ac49-45d8-8a8f-ba61cdc5dc1f" -SnapResGroupName "rg-teshared-custz-test"

param ($SubscriptionId, $SnapResGroupName)

function removeSnapshot {

    $Snapshots = Get-AzSnapshot -ResourceGroupName $SnapResGroupName
    foreach ($Snapshot in $Snapshots) {
        $SnapshotName = $Snapshot.Name
        Write-Host "Removing Snapshot: $SnapshotName"
        Remove-AzSnapshot -ResourceGroupName $SnapResGroupName -Name $SnapshotName -Force
    }
}

Set-AzContext -Subscription $SubscriptionId
removeSnapshot
