get_identify_regex() => '
(
(?(DEFINE)(?<line_comment>(?<![^ `t`r`n]);.*)(?<block_comment>(?m:^[ `t]*/\*(?:.*\R?)+?(?:[ `t]*\*/|.*\Z)))(?<eol>(?=[ `t]*+(?&line_comment)?(?m:$)))(?<tosol>(?:(?&eol).*\R|(?&block_comment))++)(?<toeol>(?:[^ `t`r`n]++|[ `t]*+(?!(?&eol)))*+)(?<contsec>[ `t]*+\((?i:Join[^ `t`r`n]*+|(?&line_comment)|[^ `t`r`n()]++|[ `t]++)*+\R(?:[ `t]*+(?!\)).*\R)*+[ `t]*+\))(?<solcont>[ `t]*+(?:,(?!::| +& )|[<>=/|^,?:\.+\-*&!~](?![^"'`r`n]*?(?:".*?::(?!.*?")|'.*?::(?!.*?')|::))|(?i:AND|OR)(?=[ `t])))(?<eolcont>(?&eol)(?:(?<ec_bad>(?<=:=)|(?<=[:,]))|(?<=[<>=/|^,?:\.+\-*&!~](?<!\+\+|--))|(?<=(?<![\w[:^ascii:]\.])(?i:OR|IS|AS|IN))|(?<=(?<![\w[:^ascii:]\.])(?i:AND|NOT))|(?<=(?<![\w[:^ascii:]\.])(?i:CONTAINS)))(?&tosol)(?:(?&contsec)|(?(ec_bad)|(*:v2-cle))))(?<v1_cont>(?&tosol)(?:(?&solcont)(?&subexp)|[ `t]*+,[ `t]*+(?=%)(?&pct)|(?&contsec)(?&ambig)))(?<v1_fin>(?:.*+(?&v1_cont))*.*+)(?<ambig>(?:(?&exp)|(?&v1_cont)|.*+)++(*:~))(?<pct>(?=%[ `t])(?:(?&subexp)(?&exp)|(?&v1_fin)(*:v1-pct)))(?<expm>(*:exp)(?&exp))(?<v1_lines>(?&toeol)(?:(?&tosol)(?:(?&solcont)|(?&contsec))(?&v1_lines))?)(?<otb>(?<![<>=/|^,?:\.*&!~])(?<!(?<!\+)\+)(?<!(?<!\-)\-)[ `t]*+\{(?&eol))(?<enclf>\R(?:(?&contsec)|(?!(?&solcont))(*:v2-cbe)|))(?<encex>(?:[, `t]++|(?&enclf)|(?&subexp)|(?&line_comment))*+)(?<v2_exm>%(?:[^,`r`n;\[\]{}()"%']*+|,(?![ `t]*+%)|(?&subexp))*+%(*:v2-pct)|=>(*:v2-fat))(?<subexp>(?:(?!(?&otb))(?&eolcont)?[ `t]*+(?:[^ `t;,`r`n=\[\]{}()"%']++|\((?&encex)\)|\[(?&encex)\]|\{(?&encex)\}|(?>"(?>[^"``\r\n]|``["'``])*+"|'(?>[^'``\r\n]|``["'``])*+'(*:v2-sq))|'(?&tosol)(?&contsec)'(*:v2-sq)|(?<!\.)%[\w[:^ascii:]]++%|(?&v2_exm)|=|(?&v1_cont)))++)(?<exp>(?:(?&subexp)|[ `t]*+,|(?&eol))++(?&otb)?))(?:[ `t]*+(?&line_comment)(*SKIP)(?!)|(?m:^)[ `t{}]*(?:(?m:^[ `t]*/\*(?:.*\R?)+?(?:[ `t]*\*/|.*\Z))(*SKIP)(?!)|(?:[<>*~$!^+#]*(?>\w+|[^ `t`r`n])|~?(?>\w+|[^ `t`r`n]) & ~?(?>\w+|[^ `t`r`n]))(?i:[ `t]+up)?::(?:[<>*~$!^+#]*(?>\w+|[^ `t`r`n])(?&eol)(*:remap?)|(?&eol)(?!(?&tosol)[ `t]*+(?:[\{#]|.*?::|[\w[:^ascii:]]++\())(*:v1-hk)|(*:hotkey))|(?(?=:[^\:`r`n]*[xX]):[[:alnum:]\?\*\- ]*:([^```r`n:]++|``.|:(?!:))*?::|:[[:alnum:]\?\*\- ]*:([^```r`n:]++|``.|:(?!:))*?::(?:(?&v1_cont)|.*))(*:hotstring)|[\w[:^ascii:]]++:(?=[ `t]*+(?:(?<![^ `t`r`n]);.*)?(?m:$))(*:label)|[^ ,```r`n]+(?<!:):(?=[ `t]*+(?:(?<![^ `t`r`n]);.*)?(?m:$))(*:v1-lbl)|#(?:\w+,|(?i:NoEnv|If|CommentFlag|Delimiter|DerefChar|EscapeChar))(?&v1_fin)(*:v1-dir)|#(?i:HotIf)(*:v2-dir)(?&exp)?|#(?i:Include(?:Again)?)[ `t]+(?&v1_fin)(*:dir)|#\w+(?![^ `t`r`n])(?&ambig)(*:dir?)|(?<=[{}])(*SKIP)(?!))|[ `t]*+(?:(?!(?:[\w[:^ascii:]<>=/|^,?:\.+\-*&!~ `t()\[\]{}%]++|(?>"(?>[^"``\r\n]|``["'``])*+"|'(?>[^'``\r\n]|``["'``])*+'(*:v2-sq))|['"].*)*+(?=[ `t]*+(?:(?<![^ `t`r`n]);.*)?(?m:$)))(?&v1_fin)(*:v1-char)|(?i:else|try|finally)(?![^ `t`r`n])[ `t]*+\{?(*SKIP)(?!)|(?i:return|for|while|until|throw|switch)[ `t]++(?&expm)|(?i:if|while|return|until|loop|goto)(?=\()(?&expm)|(?i:local|global|static)(?![\w[:^ascii:]#@$])(?:[ `t]++[\w[:^ascii:]]++(?:(?=\()(?&exp)(*:v2-kw)|[ `t]*+\{(?&eol)(*:v2-kw)|(?![ `t]*+=)(?&expm))|(?&eol)(*:assume)|(?&v1_fin)(*:v1-kw))|(?i:if)[ `t]++(?:(?>[\w[:^ascii:]#@$]++|%[\w[:^ascii:]#@$]++%)++(?:[ `t]++(?i:not[ `t]++)?(?i:in|contains|between)[ `t]++(?&v1_fin)(*:v1-if)|[ `t]*+(?:[<>]=?|!?=)(?&ambig))|(?&expm))|[\w[:^ascii:]]++(?:[ `t]*+=(?:>(?&ambig)|.*?\?.+?:.*(?&ambig)|(?&v1_fin)(*:v1-ass))|[\(\[](?=.*[\)\]][ `t`r`n]*\{)(?:[ `t]*+[\w[:^ascii:]]++[ `t]*+(?::=(?&subexp))?[ `t]*+,)*+[ `t]*+(?:(?i:ByRef)[ `t]++[\w[:^ascii:]](*:v1-ref)|&(*:v2-ref)|[\w[:^ascii:]]++[ `t]*+=(*:v1-def)|\*[ `t]*+[\)\]](*:v2-vfn)).*|(?=[\(\[\.\?]|[ `t]*+(?>[\:\+\-\*/\.\|&\^]|<<|>>|//)=)(?&expm)|,(?&v1_fin)(*:v1-cmd)|(?&eol)(?&ambig)|[ `t]++(?:[ `t]*+(?:\^|(?:(?!\{)[\w[:^ascii:]<>=/|^,?:\.+\-*&!~ `t()\[\]{}%]|(?>"(?>[^"``\r\n]|``["'``])*+"|'(?>[^'``\r\n]|``["'``])*+'(*:v2-sq)))*+\{[ `t]*+(?:\w+|.)(?:[ `t]++\w+)?[ `t]*+\})(?&v1_fin)(*:v1-send)|(?:[^`r`n,\[\]{}()"%']*+,[ `t]*+)*+(?&pct)|(?&ambig)(*:cmd?)))|(?:\+\+|--)(?&expm)|.(?&ambig)(*:!!)))
)'

IdentifyBySyntax(code) {
    static identify_regex := get_identify_regex()
    p := 1, count_1 := count_2 := 0, version := marks := ''
    try while (p := RegExMatch(code, identify_regex, &m, p)) {
        p += m.Len()
        if SubStr(m.mark,1,1) = 'v' {
            switch SubStr(m.mark,2,1) {   
            case '1': count_1++
            case '2': count_2++
            }
            if !InStr(marks, m.mark)
                marks .= m.mark ' '
        }
    }
    catch as e
        return {v: 0, r: "error", err: e, pos: p}
    if !(count_1 || count_2)
        return {v: 0, r: "no tell-tale matches"}
    ; Use a simple, cautious approach for now: select a version only if there were
    ; matches for exactly one version.
    if count_1 && count_2
        return {v: 0, r: Format(
            count_1 > count_2 ? "v1 {1}:{2} - {3}" : count_2 > count_1 ? "v2 {2}:{1} - {3}" : "? {1}:{2} - {3}",
            count_1, count_2, Trim(marks)
        )}
    return {v: count_1 ? 1 : 2, r: Trim(marks)}
}