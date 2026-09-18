#!/bin/nu

def calmonth [month: int = -1, year: int = -1] {
    mut requested_month = $month
    mut requested_year = $year

    if $month == -1 {
        $requested_month = date now | format date "%m" | into int
    }

    if $year == -1 {
        $requested_year = date now | format date "%Y" | into int
    }

    cal --as-table --week-start mo --full-year $requested_year --month
        | where month == $requested_month
        | drop column --left 1
}
