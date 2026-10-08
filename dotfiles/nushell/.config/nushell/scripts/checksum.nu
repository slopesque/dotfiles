def dirchecksum [a: string, b: string] {
    let a = $a | path expand
    let b = $b | path expand

    glob --no-dir ($a)/**
        | path relative-to $a
        | each { |file|
        {
            path: $file,
            exists: ($b | path join $file | path exists),
            same: (
                ($b | path join $file | path exists)
                and (
                    ($a | path join $file | open --raw | hash sha256)
                    == ($b | path join $file | open --raw | hash sha256)
                )
            )
        }
    }
}
