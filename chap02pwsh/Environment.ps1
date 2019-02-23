class Environment {

    $level = 0

    $array = @{}

    [Environment] Duplicate() {
        $result = New-Object Environment
        $result.level = $this.level
        $result.array = $this.array.Clone()
        return $result
    }

    [void] EnterScope() {
        #Write-Host Enter Scope ($this.level) -> ($this.level+1)
        $this.level++
    }

    [void] LeaveScope() {
        #Write-Host Leave Scope ($this.level) -> ($this.level-1)
        foreach ($name in $($this.array.Keys)) {
            # TODO: if name becomes empty, remove?
            $cell = $this.array[$name]
            if ($cell.level -eq $this.level) {
                $this.array[$name] = $cell.next
            }
        }
        $this.level--
    }

    [void] Declare($name, $value) {
        #Write-Host name=$name value=$value
        if ($this.array.containsKey("$name")) {
            $cell = $this.array["$name"]
            if ($cell.level -lt $this.level) {
                $newcell = New-Object Cell -ArgumentList $this.level, $value, $cell
                $this.array[$name] = $newcell
            } else {
                $cell.value = $value    # illegal, not sure what to do ?throw an error?
            }
        } else {
            $this.array[$name] = New-Object Cell -ArgumentList $this.level, $value, $null
        }
    }

    [Exp] LookUp($name) {
        if ($this.array.containsKey("$name")) {
            $cell = $this.array["$name"]
            if ($cell -ne $null) {
                return $cell.value
            }
        }
        return $null
    }

    [boolean] Update($name, $value) {
        #Write-Host $this
        if ($this.array.containsKey("$name")) {
            $cell = $this.array["$name"]
            #Write-Host name=$name cell=$cell
            $cell.value = $value
            return $true
        }
        return $false
    }

    [boolean] UpdateDynamic($name, $value) {
        if ($this.array.containsKey("$name")) {
            $cell = $this.array["$name"]
            if ($cell.level -eq $this.level) {
                $cell.value = $value
            } else {
                $newcell = New-Object Cell -ArgumentList $this.level, $value, $cell
                $this.array[$name] = $newcell
            }
            return $true
        }
        return $false
    }

    [string] ToString() {
        $str = ""
        $this.array.Keys | foreach-object {
            if ($this.array.containsKey("$_")) {
                $cell = $this.array["$_"]
                $value = "$($cell.level):$($cell.value)"
            } else {
                $value = "null"
            }
            $str += "[$($_):$value]"
        }
        return "{env:level=$($this.level),array=$str}"
    }
}

class Cell {
    $level
    $value
    $next

    Cell($level, $value, $next) {
        $this.level = $level
        $this.value = $value
        $this.next = $next
    }
}
