/* description: Parses simple propositional logic expresssions. */

/* lexical grammar */
%lex

%options case-insensitive

%%

\s+                   /* skip whitespace */
"and"                 return 'and'
"or"                  return 'or'
"not"                 return 'not'
"("                   return '('
")"                   return ')'
[^"\s()]+             return 'STRING'
\"[^"]+\"             yytext = yytext.slice(1,-1); return 'STRING'
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
        { return $1;}
    ;

string
    : STRING {$$ = { type: 'string', value: yytext };}
    ;

strings
    : string
    | strings string {$$ = mergeCondition($1, $2, 'and');}
    ;
e
    : e 'and' e  {$$ = mergeCondition($1, $3, 'and');}
    | e 'or' e   {$$ = mergeCondition($1, $3, 'or');}
    | 'not' e    {$$ = { type: 'not', value: $2 };}
    | '(' e ')'  {$$ = $2;}
    | strings
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
