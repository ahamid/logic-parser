/* description: Parses end executes mathematical expressions. */

/* lexical grammar */
%lex

%%

\s+                   /* skip whitespace */
"and"                 return 'and'
"or"                  return 'or'
"not"                 return 'not'
"("                   return '('
")"                   return ')'
[^"\s()]+             return 'TEXT'
\"[^"]+\"             yytext = yytext.slice(1,-1); return 'TEXT'
<<EOF>>               return 'EOF'
.                     return 'INVALID'

/lex

/* operator associations and precedence */
%left 'or'
%left 'and' 
%left 'not'

%start expressions

%% /* language grammar */

expressions
    : e EOF
        { console.log(JSON.stringify($1, null, 2)); return $1;}
    ;

e
    : e 'and' e  {$$ = mergeCondition($1, $3, 'and');}
    | e 'or' e   {$$ = mergeCondition($1, $3, 'or');}
    | 'not' e    {$$ = { type: 'not', value: $2 };}
    | '(' e ')'  {$$ = $2;}
    | TEXT       {$$ = yytext;}
    ;
%%

function mergeCondition (node1, node2, type) {
  if (node1.type == type) {
    node1.values.push(node2);
    return node1;
  } else {
    return {
      type: type,
      values: [node1, node2]
    };
  }
}