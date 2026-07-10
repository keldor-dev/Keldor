class KeldorThing {
    [string]$Name
    [string]$Path
    [datetime]$CreatedAt

    KeldorThing([string]$Name, [string]$Path) {
        $this.Name = $Name
        $this.Path = $Path
        $this.CreatedAt = Get-Date
    }
}
