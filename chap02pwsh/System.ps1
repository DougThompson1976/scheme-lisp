function Make-BuiltIn($name, $env) {
    $function = New-Object Exp -ArgumentList ([ExpType]::BuiltIn)
    $function.value = New-Object Fun
    $function.value.defEnv = $env
    $env.Declare($name, $function)
}

function Make-Global-Environment() {
    $globEnv = New-Object Environment
    Make-BuiltIn "+" $globEnv
    Make-BuiltIn "-" $globEnv
    Make-BuiltIn "*" $globEnv
    Make-BuiltIn "/" $globEnv
    Make-BuiltIn "=" $globEnv
    Make-BuiltIn "EQUAL?" $globEnv
    Make-BuiltIn "DISPLAY" $globEnv
    return $globEnv
}

function Call-BuiltIn($name, $argsExp, $env, $denv) {
    $args = @()
    $cons = $argsExp
    while ($cons.type -eq "Cons") {
        $val = Evaluate $cons.car $env $denv
        $args += $val
        $cons = $cons.cdr
    }
    switch ($name.value) {
        "+" {
            return SysPlus($args)
        }
        "-" {
            return SysMinus($args)
        }
        "*" {
            return SysMult($args)
        }
        "/" {
            return SysDiv($args)
        }
        "=" {
            return SysEqNum($aargs)
        }
        "EQUAL?" {
            return SysEqual($args)
        }
        "DISPLAY" {
            return SysDisplay($args)
        }
    }
}

function SysPlus($a) {
    $result = 0
    foreach ($num in $a) {
        $result += $num.value
    }
    return New-Object Exp -ArgumentList ([ExpType]::Number), $result
}

function SysMinus($a) {
    if ($a.length -eq 0) {
        return New-Object Exp -ArgumentList ([ExpType]::Number), 0
    }
    if ($a[0].type -ne ([ExpType]::Number)) {
        return New-Object Exp -ArgumentList ([ExpType]::Number), 0
    }
    if ($a.length -eq 1) {
        New-Object Exp -ArgumentList ([ExpType]::Number), -$[a].value
    }
    $result = $a[0].value
    $i = 1
    while ($i -lt $a.length) {
        $result -= $a[$i].value
        $i++
    }
    return New-Object Exp -ArgumentList ([ExpType]::Number), $result
}

function SysMult($a) {
    $result = 1
    foreach ($num in $a) {
        $result *= $num.value
    }
    return New-Object Exp -ArgumentList ([ExpType]::Number), $result
}

function SysDiv($a) {
    if ($a.length -eq 0) {
        return New-Object Exp -ArgumentList ([ExpType]::Number), 1
    }
    if ($a[0].type -ne ([ExpType]::Number)) {
        return New-Object Exp -ArgumentList ([ExpType]::Number), 0
    }
    if ($a.length -eq 1) {
        New-Object Exp -ArgumentList ([ExpType]::Number), 0
    }
    $result = $a[0].value
    $i = 1
    while ($i -lt $a.length) {
        $result = [math]::floor($result / $a[$i].value)
        $i++
    }
    return New-Object Exp -ArgumentList ([ExpType]::Number), $result
}

function SysDisplay($a) {
    $e = New-Object Exp -ArgumentList ([ExpType]::Symbol), "NIL"
    foreach ($exp in $a) {
        $e = $exp
        Write-Host [SYS] $exp
    }
    return $e
}

function IsEqual($exp1, $exp2) {
    if ($exp1.type -ne $exp2.type) {
        return $false
    }
    if ($exp1.type -eq ([ExpType]::Cons)) {
        return (IsEqual $exp1.car $exp2.car) -and (IsEqual $exp1.cdr $exp2.cdr)
    }
    return $exp1.value -eq $exp2.value
}

function SysEqNum($a) {
    $val = $a[0].type -eq ([ExpType]::Number) -and $a[0].type -eq $a[1].type -and $a[0].value -eq $a[1].value
    return New-Object Exp -ArgumentList ([ExpType]::Boolean), $val
}

function SysEqual($a) {
    return New-Object Exp -ArgumentList ([ExpType]::Boolean), (IsEqual $a[0] $a[1])
}
