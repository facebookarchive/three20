flex --prefix=css --nounput css.grammar

cat CssTokenizerPrefix > CssTokenizer.cpp
cat lex.css.c >> CssTokenizer.cpp

rm lex.css.c

cp CssTokenizer.cpp ../Sources/CssTokenizer.m
cp CssTokens.cpp ../Sources/CssTokens.m
cp CssToken*.h ../Headers/
