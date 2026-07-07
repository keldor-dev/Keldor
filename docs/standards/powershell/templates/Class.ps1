class KeldorThing {
    [string]$Name
    [string]$Path
    [datetime]$Timestamp

    KeldorThing([string]$Name, [string]$Path) {
        $this.Name = $Name
        $this.Path = $Path
        $this.Timestamp = Get-Date
    }
}
